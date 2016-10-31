module Api
  class LikesController < ApplicationController
    before_action :require_login
    before_action :set_like, only: %w(destroy)
    before_action :manage_allowed?, only: %w(destroy)

    after_action :send_retention_messages, only: %w(create)

    # NOTE:
    #   e.g.) curl -v -H "cyAccessToken: xxxxxxxxxx" -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"episodeId": "17084"}' http://localhost:3000/api/v3/likes
    def create
      rv = UserReview.find_by( id: params[:reviewId] )
      unless rv
        render_error(message: "review not found for params: #{params}")
        return
      end

      like_params = {
        user_id: current_user.id,
        like_type: CY_LIKE_TYPE_REVIEW,
        like_id: params[:reviewId]
      }

      # NOTE: when user already liked in the past, we allow it and just return object in order to keep data consistency between server and client
      if @like = Like.where(like_params).first
        render
        return
      end

      @like = Like.new(like_params)
      if @like.save
        if rv.spot_id
          unless current_user.bookmarks.where( bk_type: CY_BK_TYPE_SPOT, bk_id: rv.spot_id ).first
            bookmark = Bookmark.new( bk_type: CY_BK_TYPE_SPOT, bk_id: rv.spot_id, user_id: current_user.id, user_review_id: rv.id)
            unless bookmark.save
              render_error(message: bookmark.errors.messages)
              return
            end
          end
        end
        head :ok
      else
        render_error(message: @like.errors.inspect)
      end
    end

    # NOTE:
    #   e.g.) curl -v -H "cyAccessToken: xxxxxxxxxx" -H "Accept: application/json" -H "Content-type: application/json" -X DELETE -d '{"episodeId": "2644"}' http://localhost:3000/api/v3/likes/:id
    def destroy
      if @is_from_ios
        # NOTE: for in case that like button has accidently tapped
        unless @like
          @review = UserReview.find( params[:reviewId] )
          return
        end
      end

      @review = @like.user_review

      if @like.destroy
        @review.reload # NOTE: to update likes_count
        head :ok
      else
        render_error(message: @like.errors.inspect)
      end
    end

    private
    def set_like
      @like = Like.find_by(id: params[:id]) || not_found
    end

    def manage_allowed?
      manage_allowed = (current_user && @like.user_id == current_user.id)
      return true if manage_allowed

      not_permitted
    end

    def send_retention_messages
      return unless @like
      @like.send_retention_mail
      # @like.send_mobile_notification
    end
  end
end
module Api
  class CommentsController < ApplicationController
    before_action :require_login
    def create
      type = params[:cmType] || CY_CM_TYPE_REVIEW
      case type
      when CY_CM_TYPE_REVIEW
        rv = UserReview.find_by(id: params[:reviewId])
        unless rv
          render_error(message: "user_review not found: #{params[:reviewId]}")
          return
        end
        @comment = Comment.new( cm_type: type, cm_id: params[:reviewId], body: params[:body] )
      when CY_CM_TYPE_TRIPNOTE
        @comment = Comment.new( cm_type: type, cm_id: params[:logbookId], body: params[:body])
      end

      @comment.user_id = current_user.id

      if @comment.save
        head :created
      else
        render_error(message: @comment.errors.inspect)
      end
    end
  end
end
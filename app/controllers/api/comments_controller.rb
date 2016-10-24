module Api
  class CommentsController < ApplicationController
    before_action :require_login

    def create
      type = params[:cmType] || CY_CM_TYPE_REVIEW
      case type
      when CY_CM_TYPE_REVIEW
        #ep = Episode.find_by(id: params[:episodeId])
        #unless ep
        #  render_error(message: "episode not found: #{params[:episodeId]}")
        #  return
        #end
        #@comment = Comment.new( cm_type: type, cm_id: params[:episodeId], body: params[:body] )
      when CY_CM_TYPE_TRIPNOTE
        @comment = Comment.new( cm_type: type, cm_id: params[:logbookId], body: params[:body] )
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


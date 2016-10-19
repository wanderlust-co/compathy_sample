class UserPhotosController < ApplicationController

  before_action :set_logbook, only: %w(with_episode)

  def new
    @user_photo = UserPhoto.new
  end

  def with_episode
    user_photo = UserPhoto.new(image: params[:image] , user: current_user)

    ActiveRecord::Base.transaction do
      if user_photo.save
        if @review = UserReview.create_with_photo(@tripnote.user, @tripnote, user_photo)
          user_photo.update(user: @tripnote.user, tripnote: @tripnote, user_review: @review)
          unless @tripnote.user_photo_id
            @tripnote.update(user_photo_id: user_photo.id)
          end
        end
      end
    end
  end

  def create
  end

  private
  def photo_params
    params.require(:user_photo).permit(:image)
  end

  def set_logbook
    @tripnote = Tripnote.find(params[:logbookId]) rescue not_found
  end
end

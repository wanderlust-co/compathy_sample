class UserPhotosController < ApplicationController

  before_action :set_logbook, only: %w(with_episode)

  def new
    @user_photo = UserPhoto.new
  end

  def create
    @user_photo = UserPhoto.new(photo_params)
    if @user_photo.save
      redirect_to :root
    end
  end

  def with_episode
    user_photo = UserPhoto.new( image: params[:image], user: current_user )
    binding.pry
    ActiveRecord::Base.transaction do
      if user_photo.save
        if @episode = UserReview.create_with_photo(@logbook.user, @logbook, user_photo)
          user_photo.update(user: @logbook.user, tripnote: @logbook, user_review: @episode)

          unless @logbook.user_photo_id
            @logbook.update(user_photo_id: user_photo.id)
          end
        end
      end
    end
    render json: { logbook: @logbook }
  end

  private
  def photo_params
    params.require(:user_photo).permit(:image)
  end

  def set_logbook
    binding.pry
    @logbook = Tripnote.find(params[:logbookId]) rescue not_found
  end
end

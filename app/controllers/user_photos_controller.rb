class UserPhotosController < ApplicationController

  def new
    @user_photo = UserPhoto.new
  end

  def create
    @user_photo = UserPhoto.new(photo_params)
    if @user_photo.save
      redirect_to :root
    end
  end

  private
  def photo_params
    params.require(:user_photo).permit(:image)
  end
end

class TripnotesController < ApplicationController
  before_action :set_tripnote, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login, only: [:index, :show]

  def index
    @tripnotes =  Tripnote.all
  end

  def new
    @tripnote = Tripnote.new
    @tripnote.user_reviews.build
    @tripnote.user_reviews.first.user_photos.build
  end

  def create
    tripnote = Tripnote.new(tripnote_params)
    tripnote.save
    redirect_to new_tripnote_path
    # if @tripnote = Tripnote.create(tripnote_params)
    #   user_review = UserReview.new
    #   user_review.tripnote_id = @tripnote.id
    #   user_photo = UserPhoto.new
    #   user_photo.user_review_id = user_review.id
    #   if params[:images]
    #     params[:images].each { |image|
    #       @tripnote.user_reviews.user_photos.create(image: image)
    #         redirect_to :root
    #     }
    #   end
    # end
  end

  def show
  end

  def edit
  end

  private
  def set_tripnote
    @tripnote = Tripnote.find(params[:id])
  end

  def tripnote_params
    params.require(:tripnote).permit(
      :title,
      :description,
      user_reviews_attributes: [
        :description,
        user_photos_attributes: [
          :image]
      ]
    ).merge(user_id: current_user.id)
  end
end

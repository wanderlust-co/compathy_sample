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

  def edit
  end

  def create
    tripnote = Tripnote.new(tripnote_params)
    tripnote.save
    redirect_to new_tripnote_path
  end

  def show
  end

  private
  def set_tripnote
    @tripnote = Tripnote.find(params[:id])
  end

  def prepare_tripnotes( page_numbers = [], exclude_rough: false, order_by_date: false )
    @reviews = @tripnote.user_reviews.includes(:user_photos)
    @reviews = @reviews.exc_rough if exclude_rough

    # FIXME: when you need performance tuning, add tripnote_page_number column to UserReview table.
    if page_numbers.present?
      @reviews = @reviews.select {|rev| page_numbers.include? rev.tripnote_total_order}
    end
  end

  def tripnote_params
    params.require(:tripnote).permit(:title,:description).merge(user_id: current_user.id)
  end
end

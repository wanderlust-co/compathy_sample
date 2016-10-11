class TripnotesController < ApplicationController
  before_action :set_tripnote, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login, only: [:index, :show]

  def index
    @tripnotes =  Tripnote.all
  end

  def new
    @tripnote = Tripnote.new
    # @user_photo = User_photo.new
  end

  def create
    @tripnote = Tripnote.create(tripnote_params)
    redirect_to :root
  end

  def show
  end

  private
  def set_tripnote
    @tripnote = Tripnote.find(params[:id])
  end

  def tripnote_params
    params.require(:tripnote).permit(:title, :description, :user_photos).merge(user_id: current_user.id)
  end
end

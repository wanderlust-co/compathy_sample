class TripnotesController < ApplicationController
  def index
  end

  def new
    tripnote = Tripnotes.create
  end

  def show
  end

  private
  def tripnote_params
    params.require(:tripnote).permit(:)
  end
end

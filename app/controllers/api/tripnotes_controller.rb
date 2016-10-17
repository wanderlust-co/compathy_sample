module Api
  class TripnotesController < ApplicationController
   before_action :set_tripnote, only: %w(edit)
    def edit
      prepare_tripnotes
      render :show
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_tripnote
      @tripnote = @logbook = Tripnote.find_by(id: params[:id]) || not_found
    end

    def prepare_tripnotes( page_numbers = [], exclude_rough: false, order_by_date: false )
      @reviews = @tripnote.user_reviews.includes(:user_photos)
      @reviews = @reviews.exc_rough if exclude_rough

      # FIXME: when you need performance tuning, add tripnote_page_number column to UserReview table.
      if page_numbers.present?
        @reviews = @reviews.select {|rev| page_numbers.include? rev.tripnote_total_order}
      end
    end
  end
end
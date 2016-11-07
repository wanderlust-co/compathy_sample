module Api
  class TripnotesController < Api::ApplicationController
    before_action :set_tripnote, only: %w(edit update add_cover_photo set_cover_photo set_openness)
    before_action :require_login, only: %w(edit update add_cover_photo set_cover_photo set_openness)

    def edit
      prepare_tripnotes
      render :show
    end

    def set_cover_photo
      @photo = UserPhoto.find( params[:cover_photo_id] )
      @tripnote.update!( user_photo: @photo )
      render :add_cover_photo
    rescue => ex
      logger.error "#{self.class.to_s}##{__method__.to_s}: #{ex.message}: #{@photo.errors.inspect if @photo}"
      render json: {
        responseStatus: 1500,
        responseMessage: "search failed: #{ex.message}",
        responseBody: nil
      }, status: :unprocessable_entity
    end

    def add_cover_photo
      raise "it requires params :image" unless params[:image]
      @photo = UserPhoto.new(
        image: params[:image],
        image_lat: params[:lat],
        image_lng: params[:lng],
        user: current_user,
        tripnote: @tripnote,
        client_file_identifier: params[:imageKeyString]
      )

      if @photo.save!
        if params[:editingPublished]
          @tripnote.user_photo_id = @photo.id
        else
          @tripnote.update!( user_photo_id: @photo.id )
        end
      end
    rescue => ex
      logger.error "#{self.class.to_s}##{__method__.to_s}: #{ex.message}: #{@photo.errors.inspect if @photo}"
      render json: {
        responseStatus: 1500,
        responseMessage: "search failed: #{ex.message}",
        responseBody: nil
      }, status: :unprocessable_entity
    end

    def update
      cover_param   = params[:tripnote][:cover]
      review_params = params[:tripnote][:reviews]
      # binding.pry
      # TODO: "cover_param[:theme]" is backward compatibility for compathy_ios01 v1.1.0
      tn_params = {
        title:         cover_param[:title],
        description:   cover_param[:description]
      }
      ActiveRecord::Base.transaction do
        @tripnote.update!(tn_params)

        prev_rev_ids = @tripnote.user_reviews.collect(&:id)
        post_rev_ids = []

        (review_params || []).each do |review_param|
          review = UserReview.where(id: review_param[:id], tripnote_id: @tripnote.id).first
          unless review
            logger.warn "episode not found. skip. : #{review_param.inspect}"
            next
          end
          rev_param = {
            body: review_param[:body]
          }
          review.update!(rev_param)
          post_rev_ids << review.id
        end
        removed_rev_ids = prev_rev_ids - post_rev_ids
        removed_reviews = UserReview.where(id: removed_rev_ids)
        removed_reviews.destroy_all
      end
      prepare_tripnotes
      render :show
    rescue => ex
      logger.error "#{self.class.to_s}##{__method__.to_s}: #{ex.message}: #{@tripnote.errors.inspect if @tripnote}: #{ex.backtrace.join("\n")}"
      render json: {
        responseStatus: 1500,
        responseMessage: "search failed: #{ex.message}",
        responseBody: nil
      }, status: :unprocessable_entity
    end

    def set_openness
      if params[:openness] == CY_OPENNESS[:full]
        if @tripnote.open_full!
          head :ok
          return
        end
      end
      head :ng
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_tripnote
      @tripnote = Tripnote.find_by(id: params[:id]) || not_found
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
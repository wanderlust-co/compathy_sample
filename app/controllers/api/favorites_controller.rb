module Api
  class FavoritesController < Api::ApplicationController
    before_action :require_login

    before_action :set_favorite, only: %w(destroy)
    before_action :manage_allowed?, only: %w(destroy)

    def create
      @favorite = Favorite.new(favorite_params)
      @favorite.user_id = current_user.id
      if @favorite.save
        head status: :created
      else
        render_error(message: @favorite.errors.inspect)
      end
    end

    def destroy
      if @favorite.destroy
        head :ok
      else
        render_error(message: @favorite.errors.inspect)
      end
    end

    private
    def set_favorite
      @favorite = Favorite.find_by(id: params[:id]) || not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.require(:favorite).permit(:tripnote_id)
    end

    def manage_allowed?
      @manage_allowed = (@favorite.user_id == current_user.id)
      return true if @manage_allowed

      not_permitted
    end
  end
end
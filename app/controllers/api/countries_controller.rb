module Api
  class CountriesController < Api::ApplicationController
    before_action :set_country, only: %w(show tripnotes categories tags)

    def index
      if I18n.locale == :en
        @countries = Country.all
      else
        @countries = Country.includes( :country_translations, :continent )
                            .references( :country_translations, :continent )
                            .where( "country_translations.locale = ?", I18n.locale )
      end
      # NOTE: allがあるとすべての国だけ返す、そうじゃないとログブックのある国だけを返す
      @countries = @countries.where.not( published_tripnotes_count: 0 ) unless params[:all]

      # NOTE: work-around for no flag countries
      @countries = @countries.where.not( cc: CY_NO_FLAG_CC_LIST_TMP )
    end

    def ranking_by_tripnote
      @countries = Country.where( "cc != 'JP'").order( "published_tripnotes_count DESC" ).limit(20)
    end

    def tags
      @user_tripnotes = @country.tripnotes_by_tag( params[:tag_name] ).page(params[:page]).per(params[:per])
    end

    def tripnotes
      # NOTE: as its SPA + infinit scroll, we serve only @country info so far.
    end

    private
      def set_country
        @country   = Country.where( url_name: params[:country_name] ).first || ( not_found and return )
        @continent = @country.continent
      end
  end
end
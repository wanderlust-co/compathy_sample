module Api
  class PlansController < Api::ApplicationController
    before_action :require_login, except: %w(preview)
    before_action :set_plan, only: %w(show edit preview update destroy create_public_link delete_public_link)
    before_action :manage_allowed?, only: %w(edit update destroy create_public_link delete_public_link)
    before_action :access_allowed?, only: %w(preview)

    def show
      # need for testing
    end

    # TODO: temporary feature for 11/30 release
    #       as it allows to have only 1 plan per user for now
    def find_or_create
      @plan = current_user.plans.first
        # binding.pry
      unless @plan
        if params[:start].present? && params[:end].present?
          d_from = Date.parse(params[:start])
          d_to   = Date.parse(params[:end])
        else
          d_from = Date.today + 1.week
          d_to   = Date.today + 1.week
        end
        @plan = current_user.plans.new(
          date_from: d_from,
          date_to: d_to,
          title: I18n.t('travel_plan.create.default_title', :name => current_user.name)
        )
        unless @plan.save
          render_error(message: @plan.errors.inspect)
          return
        end
      end
      render :show
    end

    def create
      @plan = current_user.plans.new(plan_params)
      if @plan.save
        render :show
      else
        render_error(message: @plan.errors.inspect)
      end
    end

    def edit
      render :show
    end

    private

    def set_plan
      @plan = Plan.find_by(id: params[:id]) || not_found
    end

    def manage_allowed?
      @plan.is_editable_for?(current_user) || not_permitted
    end

    def access_allowed?
      @plan.is_accessible_for?(current_user, params[:key]) || not_permitted
    end

    def plan_params
      {
        title:       params[:plan][:title],
        description: params[:plan][:description],
        date_from:   params[:plan][:dateFrom],
        date_to:     params[:plan][:dateTo]
      }
    end
  end
end

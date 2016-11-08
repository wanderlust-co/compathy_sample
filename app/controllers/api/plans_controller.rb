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

    def update
      pre_p_item_ids = @plan.plan_items.map(&:id)
      cur_p_item_ids = []

      ActiveRecord::Base.transaction do
        if @plan.update(plan_params)
          @plan.plan_item_mappings.destroy_all
          params[:plan][:dailyPlans].each do |param_daily_plan|
            count_order = 0
            date = param_daily_plan[:date]

            (param_daily_plan[:planItems] || []).each do |param_plan_item|
              count_order += 1
              cur_p_item_ids << param_plan_item[:id].to_i if param_plan_item[:id]

              p_item = PlanItem.find_or_initialize_by(id: param_plan_item[:id], plan_id: @plan.id)

              unless p_item
                logger.warn "PlanItem not found. skip. : #{param_plan_item.inspect}"
                next
              end

              param_spot = param_plan_item[:spot]
              unless param_spot && param_spot[:id]
                render_error(message: "param_plan_item: #{param_plan_item[:id]} should have spot param")
                fail ActiveRecord::Rollback
              end

              p_item.plan_id = @plan.id
              p_item.spot_id = param_spot[:id]
              p_item.body = param_plan_item[:body].presence

              if p_item.save
                map = @plan.plan_item_mappings.new(
                  date: date,
                  order: count_order,
                  plan_item: p_item
                )
                unless map.save
                  render_error(message: map.errors.inspect)
                  fail ActiveRecord::Rollback
                end
              else
                render_error(message: p_item.errors.inspect)
                fail ActiveRecord::Rollback
              end
            end
          end
          rm_p_item_ids = pre_p_item_ids - cur_p_item_ids
          PlanItem.where(id: rm_p_item_ids).destroy_all
          @plan.reload
          render :show
        else
          render_error(message: @plan.errors.inspect)
        end
      end
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

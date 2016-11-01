class TemplatesController < ApplicationController
  include CyUrlEncoder

  layout false

  def get_tpl
    render(template: "templates/#{params[:template]}")
  end
end
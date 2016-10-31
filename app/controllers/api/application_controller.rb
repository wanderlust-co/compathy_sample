module Api
  class ApplicationController < ActionController::Base
    def not_found
      render json: {
        responseStatus: 1404,
        responseMessage: "not found",
        responseBody: nil
      }, status: :not_found
    end

    def not_permitted
      render json: {
        responseStatus: 1403,
        responseMessage: "not permitted",
        responseBody: nil
      }, status: 403
    end

    def render_error(message: "response message")
      logger.error(message + ": " + caller.join("\n"))
      render json: {
        responseStatus: 1500,
        responseMessage: message,
        responseBody: "error"
      }, status: :ng
    end
  end
end
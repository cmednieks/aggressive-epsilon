module V1
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :destroy_session

    attr_accessor :service
    before_action :set_service

    private

    def destroy_session
      request.session_options[:skip] = true
    end

    def deny_access!(message = nil)
      if message.present?
        render json: { message: message }, status: :unauthorized
      else render nothing: true, status: :unauthorized
      end
    end

    def set_service
      @service = authenticate_with_http_token do |token, _options|
        Service.find_by api_key: token
      end
      deny_access! and return unless @service.present?
    end
  end
end

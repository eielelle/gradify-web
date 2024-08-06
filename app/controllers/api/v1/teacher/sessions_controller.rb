# frozen_string_literal: true

class Api::V1::Teacher::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session
  respond_to :json
  private

  def respond_with(resource, _opts = {})
    
    render json: {
      status: {code: 200, message: 'Logged in sucessfully.'},
      data: TeacherSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    puts current_teacher_account.inspect
    puts current_admin_account.inspect
    if current_teacher_account
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
  # before_action :configure_sign_in_params, only: [:create]

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end

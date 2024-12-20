# frozen_string_literal: true

module Api
    module V1
      module Student
        class SessionsController < Devise::SessionsController
          protect_from_forgery with: :null_session
          respond_to :json
  
          private
  
          def respond_with(resource, _opts = {})
            if resource.id.nil?
              log_in_fail
            else
              log_in_success
            end
          end
  
          def respond_to_on_destroy
            if current_user
              current_user.generate_jti
              log_out_success
            else
              log_out_fail
            end
          end
  
          def log_in_success
            token = current_user.jti # Or however you generate the JWT token
            render json: {
              status: { code: 200, message: 'Logged in successfully.' },
              data: StudentSerializer.new(resource).serializable_hash[:data][:attributes],
              token: token # Include the token here
            }, status: :ok
          end
  
          def log_in_fail
            render json: {
              status: { code: 401, message: 'Incorrect email or password' },
              errors: ['Incorrect email or password']
            }, status: :unauthorized
          end
  
          def log_out_success
            render json: {
              status: 200,
              message: 'Logged out successfully'
            }, status: :ok
          end
  
          def log_out_fail
            render json: {
              status: 401,
              message: "Couldn't find an active session."
            }, status: :unauthorized
          end

        end
      end
    end
  end
  
module Api
    module V1
        module Teacher
            class AuthController < ApplicationController
                before_action :check_auth
                respond_to :json

                private

                def check_auth
                    if current_user.nil?
                        render json: unauthorized, status: :unauthorized
                    else
                        if current_user.role != 'teacher'
                            render json: unauthorized, status: :unauthorized
                        end
                    end
                end

                def unauthorized
                    return {
                        status: 401,
                        message: "Unauthorized",
                        errors: [
                            "Not currently logged in"
                        ]
                    }
                end
            end
        end
    end
end
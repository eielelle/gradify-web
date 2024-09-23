module Api
    module V1
      module Teacher
        class SessionsController < ActionController::Base
            respond_to :json

            def index
                
            end

            private

            def class_params
                params.permit(:token, :sort, :search)
            end


        end
    end
end

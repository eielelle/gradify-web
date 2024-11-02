module Api
    module V1
        module Teacher
            class ResponsesController < AuthController
                respond_to :json
                protect_from_forgery with: :null_session

                    def create
                        user = User.find_by(student_number: response_params[:student_number])
                        user_id = user ? user.id : nil

                        response = Response.find_or_initialize_by(exam_id: response_params[:exam_id], user_id: user_id)
                        response.assign_attributes(response_params.merge(user_id: user_id))

                        if (response.save)
                            render json: response
                        else
                            render json: { errors: response.errors.full_messages }, status: :unprocessable_entity
                        end
                    end

                    def index
                        responses = Response.where(exam_id: params[:exam_id]) || []

                        render json: {
                            responses: ResponseSerializer.new(responses).serializable_hash[:data]
                        }
                    end

                private

                def response_params
                    params.permit(:exam_id, :student_number, :answer, :score, :detected, :image_path)
                end
            end
        end
    end
end
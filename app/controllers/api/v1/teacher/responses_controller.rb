module Api
    module V1
        module Teacher
            class ResponsesController < AuthController
                respond_to :json
                protect_from_forgery with: :null_session
                    def create_many
                        # Initialize an empty array to store the responses
                        responses = []
                    
                        # Process each response in the array from the request
                        response_params[:responses].each do |response_param|
                            # Find the exam
                            exam = Exam.find(response_param[:exam_id])
                        
                            # Find the user based on the student number and check if the user belongs to the subject
                            user = User.where(student_number: response_param[:student_number]).find_by(id: exam.subject.users.ids)
                            user_id = user ? user.id : nil
                        
                            # Find or initialize the response object
                            response = Response.find_or_initialize_by(exam_id: response_param[:exam_id], user_id: user_id)
                            response.assign_attributes(response_param.merge(user_id: user_id))
                        
                            # Add the response to the responses array if valid
                            if response.valid?
                                responses << response
                            end
                        end
                    
                        # If there are valid responses, bulk create them
                        if responses.any?
                            Response.import responses # This requires 'activerecord-import' gem for bulk import
                            render json: responses, status: :created
                        else
                            render json: { errors: 'No valid responses provided' }, status: :unprocessable_entity
                        end
                    end

                    def create
                        # Find the exam
                        exam = Exam.find(response_params[:exam_id])

                        # Find the user based on the student number and check if the user belongs to the subject
                        user = User.where(student_number: response_params[:student_number]).find_by(id: exam.subject.users.ids)
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
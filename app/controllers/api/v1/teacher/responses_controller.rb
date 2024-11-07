module Api
    module V1
        module Teacher
            class ResponsesController < AuthController
                respond_to :json
                protect_from_forgery with: :null_session
                    def create_many
                        # # Initialize an empty array to store the responses
                        responses = []
                    
                        # Process each response in the array from the request
                        response_bulk_params.each do |response_param|
                            # Find the exam
                            exam = Exam.find(response_param[:exam_id])

                            # Find the user based on the student number and check if the user belongs to the subject
                            user = User.where(student_number: response_param[:student_number]).find_by(id: exam.subject.users.ids)
                            user_id = user ? user.id : nil

                            # Find or initialize the response object
                            response = Response.find_or_initialize_by(exam_id: response_param[:exam_id], user_id: user_id)
                            response.id = nil
                            response.assign_attributes(response_param.merge(user_id: user_id))


                            # Add the response to the array if it's valid
                            if response.valid?
                                a = Response.where(exam_id: response.exam_id, user_id: response.user_id)
                                if a.nil?
                                    responses << response
                                end
                            end
                        end
                    
                        # If there are valid responses, bulk create them
                        if responses.any?
                            Response.import(
                                responses,
                                on_conflict: {
                                  conflict_target: [:exam_id, :user_id],  # Check for conflict on exam_id and user_id
                                  columns: :all  # Update all columns in case of a conflict
                                }
                              )
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

                def response_bulk_params
                    params.require(:responses).map do |x|
                        x.permit(:exam_id, :student_number, :answer, :score, :detected, :image_path)
                    end
                end
            end
        end
    end
end
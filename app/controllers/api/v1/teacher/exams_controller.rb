module Api
    module V1
        module Teacher
            class ExamsController < AuthController
                respond_to :json

                def index
                    teacher = current_user
                    
                    if current_user.nil?
                        render json: unauthorized, status: :unauthorized
                    else
                        subject = teacher.subjects.all
                        exams = Exam.where(subject_id: subject)
    
                        render json: {
                            exams: ExamSerializer.new(exams).serializable_hash[:data]
                        }
                    end
                end

                private

                def unauthorized
                    return {
                        status: 401,
                        message: "Unauthorized",
                        errors: [
                            "Not currently logged in"
                        ]
                    }
                end

                def serialize_exam(exams)
                    n = exams.map do |exam|
                        quarter = Quarter.find_by(id: exam[:quarter_id])
                        subject = Subject.find_by(id: exam[:subject_id])

                        return {
                            exam:,
                            quarter:,
                            subject:
                        }
                    end
                end
            end
        end
    end
end
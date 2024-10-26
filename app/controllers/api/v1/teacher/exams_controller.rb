module Api
    module V1
        module Teacher
            class ExamsController < ApplicationController
                include JsonHelper
                respond_to :json
    
                def index
                    teacher = current_user
                    subject = teacher.subjects.all
                    exams = Exam.where(subject_id: subject)
                    exam_data = ExamSerializer.new(exams).serializable_hash[:data]
    
                    puts "HERE"
                    puts @exams.inspect
                    render json: {
                        exams: transform_data(exam_data)
                    }
                end

                private

                def find_user

                end
            end
        end
    end

end
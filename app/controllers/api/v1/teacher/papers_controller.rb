# frozen_string_literal: true

module Api
    module V1
      module Teacher
        class PapersController < ApplicationController
          respond_to :json
          before_action :authenticate_user!
          before_action :set_teacher
          before_action :set_subject, only: [:show, :exam_details, :student_exam_overview]
          before_action :set_exam, only: [:exam_details, :student_exam_overview]
          before_action :set_student, only: [:student_exam_overview]
  
          # GET /api/v1/teacher/papers
          def index
            subjects = @teacher.subjects.includes(:school_classes)
            assignments = @teacher.school_sections
                                .includes(school_year: { school_class: :subjects })
                                .group_by { |section| section.school_year.school_class.subjects }
  
            render json: {
              data: {
                subjects: SubjectSerializer.new(subjects).serializable_hash[:data],
                assignments: assignments.map do |subjects, sections|
                  {
                    subjects: SubjectSerializer.new(subjects).serializable_hash[:data],
                    sections: SectionSerializer.new(sections).serializable_hash[:data]
                  }
                end
              }
            }
          end
  
          # GET /api/v1/teacher/papers/:id
          def show
            exams = @subject.exams.includes(:subject)
  
            render json: {
              data: {
                subject: SubjectSerializer.new(@subject).serializable_hash[:data],
                exams: ExamSerializer.new(exams).serializable_hash[:data]
              }
            }
          end
  
          # GET /api/v1/teacher/papers/:id/exam_details/:exam_id
          def exam_details
            students = User.joins(:school_sections, :subjects)
                          .where(role: 'student')
                          .where(school_sections: { id: @teacher.school_section_ids })
                          .where(subjects: { id: @subject.id })
                          .distinct
  
            render json: {
              data: {
                subject: SubjectSerializer.new(@subject).serializable_hash[:data],
                exam: ExamSerializer.new(@exam).serializable_hash[:data],
                students: StudentSerializer.new(students).serializable_hash[:data]
              }
            }
          end
  
          # GET /api/v1/teacher/papers/:id/student_exam_overview/:exam_id/:student_id
          def student_exam_overview
            answer_key = @exam.answer_key
  
            render json: {
              data: {
                subject: SubjectSerializer.new(@subject).serializable_hash[:data],
                exam: ExamSerializer.new(@exam).serializable_hash[:data],
                student: StudentSerializer.new(@student).serializable_hash[:data],
                exam_details: {
                  answer_key: answer_key,
                  # You can add additional analysis data here as needed:
                  # student_answers: @student.exam_results.where(exam: @exam).pluck(:answers).first,
                  # average_correct: calculate_average_correct,
                  # difficulty_index: calculate_difficulty_index,
                  # discrimination_index: calculate_discrimination_index
                }
              }
            }
          end
  
          private
  
          def set_teacher
            @teacher = current_user
          end
  
          def set_subject
            @subject = @teacher.subjects.find(params[:id])
          end
  
          def set_exam
            @exam = @subject.exams.find(params[:exam_id])
          end
  
          def set_student
            @student = User.find(params[:student_id])
          end
  
          # Add these methods when you implement the analysis features
          # def calculate_average_correct
          # end
  
          # def calculate_difficulty_index
          # end
  
          # def calculate_discrimination_index
          # end
        end
      end
    end
  end
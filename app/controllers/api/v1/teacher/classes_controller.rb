# frozen_string_literal: true

module Api
  module V1
    module Teacher
      class ClassesController < AuthController
        respond_to :json
        # before action current user
        
        def get_classes
          # get masterlist
          user_id = current_user.id

          school_classes = SchoolClass
          .joins(school_sections: :users)
          .where(users: { id: user_id, role: 'teacher' })
          .distinct

          render json: {
            classes: ClassSerializer.new(school_classes).serializable_hash[:data]
          }
        end

        def get_school_years
          # get school year based on class
          school_class = SchoolClass.find(params[:class_id])
          school_years = school_class.school_years

          render json: {
            years: YearSerializer.new(school_years).serializable_hash[:data]
          }
        end

        def get_sections
          school_class = SchoolClass.find(params[:class_id])
          school_year = school_class.school_years.find_by(id: params[:sy_id])
          sections = SchoolSection.where(school_year_id: school_year.id) || []

          render json: {
            sections: SectionSerializer.new(sections).serializable_hash[:data]
          }
        end

        def get_subjects
          school_class = SchoolClass.find(params[:class_id])
          subjects = school_class.subjects.distinct

          render json: {
            subjects: SubjectSerializer.new(subjects).serializable_hash[:data]
          }
        end

        def get_students
          section = SchoolSection.find(params["section_id"])
          students = section.users.where(role: 'student')


          render json: {
            students: StudentSerializer.new(students).serializable_hash[:data]
          }
        end

      end
    end
  end
end

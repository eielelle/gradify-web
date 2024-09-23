# frozen_string_literal: true

module Api
  module V1
    module Teacher
      class ClassesController < ApplicationController
        respond_to :json
        # before action current user

        def index
          sections = current_user.school_sections.ids
          years = SchoolYear.where(id: sections).ids
          classes = SchoolClass.where(id: years)

          render json: {
            classes: ClassSerializer.new(classes).serializable_hash[:data]
          }
        end

        def year_and_sections
          school_class = SchoolClass.find(JSON.parse(request.body.read)['id'])
          years = school_class.school_years
          sections = school_class.school_sections

          render json: {
            sections: SectionSerializer.new(sections).serializable_hash[:data],
            years: YearSerializer.new(years).serializable_hash[:data]
          }
        end

        def students
          find_students

          render json: {
            students: StudentSerializer.new(students).serializable_hash[:data]
          }
        end

        private

        def find_students
          body = JSON.parse(request.body.read)

          school_class = SchoolClass.find(body['class_id'])
          years = school_class.school_years.find(body['sy_id'])
          sections = years.school_sections.find(body['section_id'])
          sections.users.where(role: 'student')
        end
      end
    end
  end
end

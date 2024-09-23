module Api
    module V1
      module Teacher
        class ClassesController < ActionController::Base
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
              school_class = SchoolClass.find(params[:id])
              years = school_class.school_years
              sections = school_class.school_sections

              render json: {
                sections: SectionSerializer.new(sections).serializable_hash[:data],
                years: YearSerializer.new(years).serializable_hash[:data]
              }
            end

            def students
              school_class = SchoolClass.find(params[:class_id])
              years = school_class.school_years.find(params[:sy_id])
              sections = school_class.school_sections.find(params[:section_id])
              students = sections.users.where(role: 'student')

              render json: {
                students: StudentSerializer.new(students).serializable_hash[:data]
              }
            end

            private

            def class_params
                params.permit(:sort, :search)
            end
        end
      end
    end
end

# frozen_string_literal: true

module Teacher
  module Papers
    class ManageController < Teacher::LayoutController
      before_action :authenticate_user!
      
      def index
        @teacher = current_user

        @subjects = @teacher.subjects.includes(:school_classes) # Fetch the subjects and related school classes

        @assignments = @teacher.school_sections
                       .includes(school_year: { school_class: :subjects })
                       .group_by { |section| section.school_year.school_class.subjects }
      end

      def exam; end
    end
  end
end

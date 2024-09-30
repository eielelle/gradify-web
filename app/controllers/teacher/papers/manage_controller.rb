# frozen_string_literal: true

module Teacher
  module Papers
    class ManageController < Teacher::LayoutController
      before_action :authenticate_user!

      def index
        @teacher = current_user
        @assignments = @teacher.school_sections.includes(school_year: { school_class: :subject })
                              .group_by { |section| section.school_year.subjects }
      end
    end
  end
end

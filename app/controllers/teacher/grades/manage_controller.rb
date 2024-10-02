# frozen_string_literal: true

module Teacher
  module Grades
    class ManageController < Teacher::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern
      
      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(Exam, params)
      end
    end
  end
end

# frozen_string_literal: true

module Teacher
  module Classes
    class ManageController < Teacher::LayoutController
      include SearchableConcern
      include ErrorConcern

      def index; end
    end
  end
end

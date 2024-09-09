# frozen_string_literal: true

module Admin
  module Students
    class PasswordController < Admin::LayoutController
      include ErrorConcern
      include PasswordConcern

      def edit
        @student = User.find_by(id: params[:id], role: "student")
        redirect_to admin_students_manage_index_path if @student.nil?
      end

      def update
        update_model_password resource_class: User
      end

      private

      def edit_password_path
        edit_admin_students_password_path
      end

      def after_update_path
        admin_students_manage_index_path
      end
    end
  end
end

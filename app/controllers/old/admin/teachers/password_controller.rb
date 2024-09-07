# frozen_string_literal: true

module Admin
  module Teachers
    class PasswordController < Admin::LayoutController
      include ErrorConcern
      include PasswordConcern

      def edit
        @teacher = TeacherAccount.find_by(id: params[:id])
        redirect_to admin_teachers_manage_index_path if @teacher.nil?
      end

      def update
        update_model_password resource_class: TeacherAccount
      end

      private

      def edit_password_path
        edit_admin_teachers_password_path
      end

      def after_update_path
        admin_teachers_manage_index_path
      end
    end
  end
end

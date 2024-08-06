# frozen_string_literal: true

module Admin
  module Students
    class PasswordController < Admin::LayoutController
      include ErrorConcern
      include PasswordConcern

      def edit
        @student = StudentAccount.find_by(id: params[:id])
        redirect_to admin_students_manage_index_path if @student.nil?
      end

      def update
        @student = StudentAccount.find(params[:id])
        if @student.update(password_params)
          flash[:toast] = 'Password updated successfully.'
          redirect_to admin_students_manage_index_path
        else
          flash[:error] = 'Failed to update password.'
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def password_params
        params.require(:student_account).permit(:password, :password_confirmation)
      end
    end
  end
end

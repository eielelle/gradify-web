# frozen_string_literal: true

module Admin
  module Subjects
    class ManageController < Admin::LayoutController
      include SearchableConcern
      include ErrorConcern
      include PaperTrailConcern

      before_action :set_subject, only: %i[edit update]
      before_action :set_search, only: %i[index new create edit update]

      def index
        set_default_sort(default_sort_column: 'name asc')
        query_items_default(Subject.includes(:school_class), params) 

        set_sort_fields(%w[name updated_at])
      end

      def new
        @subject = Subject.new
        @school_classes = SchoolClass.all.order(:name)
      end

      def create
        @subject = Subject.new(subject_params)
        if @subject.save
          flash[:toast] = 'Subject added successfully.'
          redirect_to admin_subjects_manage_index_path
        else
          @school_classes = SchoolClass.all.order(:name)
          handle_errors(@subject)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @school_classes = SchoolClass.all.order(:name)
      end

      def update
        if @subject.update(subject_params)
          flash[:toast] = 'Subject updated successfully.'
          redirect_to admin_subjects_manage_index_path
        else
          handle_errors(@subject)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        set_subject

        return unless @subject.destroy

        flash[:toast] = 'Subject was successfully destroyed.' # Use flash for toast notification
        redirect_to admin_subjects_manage_index_path
      end

      def show
        set_subject
      end

      private

      def set_subject
        @subject = Subject.find(params[:id])
      end

      def subject_params
        params.require(:subject).permit(:name, :description, :school_class_id)
      end

      def set_search
        @q = Subject.ransack(params[:q])
        @subjects = @q.result.order(:name).page(params[:page]).per(10)
        @sort_fields = {
          'Name': 'name asc',
          'Created At': 'created_at asc',
          'Updated At': 'updated_at asc'
        }
      end
    end
  end
end

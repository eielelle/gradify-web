module Teacher
    module Exams
      class ManageController < Teacher::LayoutController
        include SearchableConcern
        include ErrorConcern
        include PaperTrailConcern
        include GradeBookHelper
  
        def index
          set_default_sort(default_sort_column: 'name asc')
          @teacher = current_user
          
          # Get subjects assigned to the teacher
          @subjects = @teacher.subjects.includes(:school_class)
          
          # Build search query for exams
          @q = Exam.ransack(params[:q])
          @q.sorts = params[:q][:s] if params[:q]&.key?(:s)
          
          # Get exams for subjects assigned to teacher
          @items = @q.result(distinct: true)
                     .includes(:subject, :quarter)
                     .where(subject_id: @subjects.pluck(:id))
                     .page(params[:page])
                     .per(10)
          
          @count = @items.total_count
          
          @sort_fields = [
            ['Name (A-Z)', 'name asc'],
            ['Name (Z-A)', 'name desc'],
            ['Subject (A-Z)', 'subject_name asc'],
            ['Subject (Z-A)', 'subject_name desc'],
            ['Updated (Newest)', 'updated_at desc'],
            ['Updated (Oldest)', 'updated_at asc']
          ]
        end
  
        def new
          @exam = Exam.new
          @teacher = current_user
          @quarters = Quarter.all
          @subjects = @teacher.subjects.includes(:school_class)
        end
  
        def create
          @exam = Exam.new(exam_params)
          @teacher = current_user
          @quarters = Quarter.all
          @subjects = @teacher.subjects.includes(:school_class)
  
          # Verify teacher has access to the selected subject
          unless @subjects.pluck(:id).include?(@exam.subject_id.to_i)
            flash[:error] = "You are not authorized to create exams for this subject."
            return redirect_to new_teacher_exams_manage_path
          end
  
          # Set default items
          @exam.items = 50
          @exam.answer_key = collect_answers
  
          return unless answer_validation
  
          if @exam.save
            flash[:toast] = 'Exam was successfully created.'
            redirect_to teacher_exams_manage_index_path
          else
            handle_errors(@exam)
            flash[:error] = @exam.errors.full_messages.join(', ')
            redirect_to new_teacher_exams_manage_path
          end
        end
  
        def show
          set_exam
          authorize_exam_access
        end
  
        def edit
          set_exam
          authorize_exam_access
          @quarters = Quarter.all
          @subjects = current_user.subjects.includes(:school_class)
        end
  
        def update
          set_exam
          authorize_exam_access
          
          @exam.answer_key = collect_answers
          
          if @exam.update(update_exam_params)
            update_success
          else
            handle_errors(@exam)
            redirect_to edit_teacher_exams_manage_path(@exam)
          end
        end
  
        private
  
        def set_exam
          @exam = Exam.find(params[:id])
        end
  
        def authorize_exam_access
          unless current_user.subjects.pluck(:id).include?(@exam.subject_id)
            flash[:error] = "You are not authorized to access this exam."
            redirect_to teacher_exams_manage_index_path
          end
        end
  
        def exam_params
          params.require(:exam).permit(:name, :subject_id, :quarter_id)
        end
  
        def update_exam_params
          params.require(:exam).permit(:name, :subject_id, :items, :answer_key, :quarter_id)
        end
  
        def collect_answers
          answers = []
          50.times do |i|
            answer = params["answer_#{i + 1}"]
            answers << (answer || '_')
          end
          answers.join('')
        end
  
        def answer_validation
          unanswered_items = []
          
          @exam.answer_key.split('').each_with_index do |answer, index|
            unanswered_items << (index + 1) if answer == '_'
          end
          
          if unanswered_items.any?
            if unanswered_items.length == 50
              flash[:toast] = "Questions 1 to 50 have no answer."
            else
              limited_items = unanswered_items.take(5)
              remaining_count = unanswered_items.length - limited_items.length
              message = "Item #{limited_items.join(', ')} "
              message += remaining_count > 0 ? "and #{remaining_count} more items have no answer." : "have no answer."
              flash[:toast] = message
            end
            
            @subjects = current_user.subjects.includes(:school_class)
            @exam.answer_key = collect_answers
            render :new, status: :unprocessable_entity
            return false
          end
          
          true
        end
  
        def update_success
          flash[:toast] = 'Updated Successfully.'
          redirect_to teacher_exams_manage_index_path
        end
      end
    end
  end
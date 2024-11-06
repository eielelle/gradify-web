module GradeBookHelper
    def calculate_exam_stats(student, exam)
      response = Response.find_by(user_id: student.id, exam_id: exam.id)
      return { total_score: 0, correct: 0, incorrect: 0 } unless response&.answer
  
      answer_key = exam.answer_key
      student_answers = response.answer
  
      total_items = exam.items
      correct = 0
      incorrect = 0
      double_answer = 0
      no_answer = 0
  
      0.upto(total_items - 1) do |i|
        if student_answers[i] == '*'
          no_answer += 1
        elsif student_answers[i] == '+'
          double_answer += 1
        elsif student_answers[i] == answer_key[i]
          correct += 1
        else
          incorrect += 1
        end
      end
  
      {
        total_score: correct,
        correct: correct,
        incorrect: incorrect,
        double_answer: double_answer,
        no_answer: no_answer
      }
    end
  
    def calculate_average(student, subject, exams)
      total_score = 0
      total_possible = 0
      
      exams.where(subject: subject).each do |exam|
        stats = calculate_exam_stats(student, exam)
        total_score += stats[:total_score]
        total_possible += exam.items
      end
      
      return 0 if total_possible.zero?
      ((total_score.to_f / total_possible) * 100).round(2)
    end
  end
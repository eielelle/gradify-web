# frozen_string_literal: true

class ExamSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :subject_id, :items, :answer_key, :created_at, :updated_at
  end
  
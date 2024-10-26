# frozen_string_literal: true

class ExamSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :items, :answer_key, :created_at, :updated_at, :name

    # has_one :subject
  end
  
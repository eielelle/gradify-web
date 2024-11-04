# frozen_string_literal: true

class ExamSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :items, :quarter_id, :subject_id, :answer_key, :created_at, :updated_at

  attribute :quarter do |event|
    # Find the quarter by its ID
    quarter = Quarter.find(event.quarter_id) if event.quarter_id
    QuarterSerializer.new(quarter).serializable_hash[:data][:attributes] if quarter
  end

  attribute :subject do |event|
    # Find the subject by its ID
    subject = Subject.find(event.subject_id) if event.subject_id
    SubjectSerializer.new(subject).serializable_hash[:data][:attributes] if subject
  end

  attribute :responses do |event|
    responses = event.responses.size;
  end
end
  
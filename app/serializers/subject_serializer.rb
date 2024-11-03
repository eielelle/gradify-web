# frozen_string_literal: true

class SubjectSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :description, :created_at, :school_class_id
  end
  
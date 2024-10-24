# frozen_string_literal: true

class ClassSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :description, :created_at, :updated_at
end

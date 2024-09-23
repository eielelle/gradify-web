# frozen_string_literal: true

class StudentSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :email, :created_at, :updated_at
end

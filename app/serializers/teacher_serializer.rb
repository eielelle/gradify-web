# frozen_string_literal: true

class TeacherSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :created_at
end

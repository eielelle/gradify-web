# frozen_string_literal: true

class SubjectUserSerializer
    include JSONAPI::Serializer
    attributes :user_id, :subject_id
  end
  
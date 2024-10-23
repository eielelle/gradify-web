# frozen_string_literal: true

class SubjectSerializer
    include JSONAPI::Serializer
    attributes :user_id, :school_section_id, :subject_id
  end
  
# frozen_string_literal: true

class SectionSerializer
  include JSONAPI::Serializer
  attributes :id, :school_year_id, :name, :created_at
end

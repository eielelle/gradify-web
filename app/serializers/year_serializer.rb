# frozen_string_literal: true

class YearSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :start, :end, :created_at
end

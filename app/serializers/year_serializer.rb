class YearSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :start, :end, :created_at, :updated_at
  end
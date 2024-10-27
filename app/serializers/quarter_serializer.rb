class QuarterSerializer
    include JSONAPI::Serializer
  
    attributes :id, :name
  end
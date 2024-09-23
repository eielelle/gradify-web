class StudentSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :email, :created_at, :updated_at
end
 
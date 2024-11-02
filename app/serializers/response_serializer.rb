# frozen_string_literal: true

class ResponseSerializer
    include JSONAPI::Serializer
    attributes :id, :exam_id, :user_id, :student_number, :image_path, :created_at, :updated_at, :detected, :score, :answer

    attribute :user do |event|
      # Find the user by its ID
      user = User.find(event.user_id) if event.user_id
      UserSerializer.new(user).serializable_hash[:data][:attributes] if user
    end
  end
    
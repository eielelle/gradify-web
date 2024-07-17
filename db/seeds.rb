# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Create Permissions
s_permission = Permission.create(name: "SuperAdmin", description: "Super Admin")
n_permission = Permission.create(name: "Admin", description: "Admin")

# Create a SuperAdmin
sudo_admin = AdminAccount.create(
  name: Faker::JapaneseMedia::StudioGhibli.character,
  email: "admin@example.com",
  password: 'password',
  permission_id: s_permission.id
)

# Create 40 Admins
40.times do
  admin = AdminAccount.create(
    name: Faker::JapaneseMedia::StudioGhibli.character,
    email: Faker::Internet.email,
    password: 'password',
    permission_id: n_permission.id
  )
end

# Create 40 Students
40.times do
  StudentAccount.create(
    name: Faker::JapaneseMedia::StudioGhibli.character,
    email: Faker::Internet.email,
    password: 'password'
  )
end

# Create 10 sections
10.times do
    Section.create!(
      name: Faker::JapaneseMedia::StudioGhibli.character,
      description: Faker::JapaneseMedia::StudioGhibli.quote,
      archived: false
    )
  end
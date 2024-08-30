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
require_relative '../lib/loading_messages'

# Check if the database already contains data for the relevant tables
if Permission.exists? || AdminAccount.exists? || TeacherAccount.exists? || SchoolClass.exists? || Section.exists? || StudentAccount.exists?
  puts "Seeding skipped: Database already contains data."
else
  Whirly.start
  Whirly.status = "Warming up...."

  # Create Permissions
  s_permission = Permission.create(name: "SuperAdmin", description: "Super Admin")
  n_permission = Permission.create(name: "Admin", description: "Admin")
  s_class = SchoolClass.create(name: "Class " + rand(1000).to_s, description: "AAA")

  Whirly.status = LoadingMessages.get

  PaperTrail.request(whodunnit: '[System Generated]') do
    # Create a SuperAdmin
    AdminAccount.create(
      name: Faker::Name.name,
      email: "admin@example.com",
      password: 'password',
      permission_id: s_permission.id
    )
    Whirly.status = LoadingMessages.get

    # Create 40 Admins
    40.times do
      AdminAccount.create(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
        permission_id: n_permission.id
      )
    end
    Whirly.status = LoadingMessages.get

    # Create 15 Teachers
    15.times do
      TeacherAccount.create(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password',
      )
    end
    Whirly.status = LoadingMessages.get

    # Create 15 SchoolClasses
    15.times do
      SchoolClass.create(name: "Class " + rand(1000).to_s, description: "AAA")
    end
  end

  # Create 10 Sections
  Whirly.status = LoadingMessages.get
  10.times do
    Section.create!(
      name: Faker::JapaneseMedia::StudioGhibli.character,
      description: Faker::JapaneseMedia::StudioGhibli.quote,
      archived: false
    )
  end

# Create 40 Students
40.times do
  StudentAccount.create(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password'
  )
end

  Whirly.stop

  puts "Seeding complete. Database has been populated with initial data."
end

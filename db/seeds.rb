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

Whirly.start
Whirly.status = "Warming up...."

Whirly.status = LoadingMessages.get
PaperTrail.request(whodunnit: '[System Generated]') do
    User.create(email: "admin@example.com", password: "password", role: "superadmin", name: "Jameson Teodore")
    User.create(email: "romero@example.com", password: "password", role: "superadmin", name: "Eleazar Romero")
    
   # Whirly.status = LoadingMessages.get
    # Initialize a counter for student numbers
    #student_counter = 1
    #3.times do
        #User.create(email: Faker::Internet.email, password: "password", role: "admin", name: Faker::Name.name)
        #User.create(email: Faker::Internet.email, password: "password", role: "student", name: Faker::Name.name, student_number: format('%05d', student_counter))
        #student_counter += 1  # Increment counter for next student
        #User.create(email: Faker::Internet.email, password: "password", role: "superadmin", name: Faker::Name.name)
       # User.create(email: Faker::Internet.email, password: "password", role: "teacher", name: Faker::Name.name)
    #end

    # Student
    Whirly.status = LoadingMessages.get
    # Initialize a counter for student numbers
    student_counter = 1
    User.create(email: "opon@gmail.com", password: "password", role: "student", name: "Job Cedric Opon", student_number: format('%05d', student_counter))
    User.create(email: "cama@gmail.com", password: "password", role: "student", name: "Johnmar Cama", student_number: format('%05d', student_counter))
    User.create(email: "remorin@gmail.com", password: "password", role: "student", name: "Kister Remorin", student_number: format('%05d', student_counter))
    User.create(email: "oleno@gmail.com", password: "password", role: "student", name: "Axel Warren Oleno", student_number: format('%05d', student_counter))
    User.create(email: "miranda@gmail.com", password: "password", role: "student", name: "Edgar Miranda", student_number: format('%05d', student_counter))
    student_counter += 1  # Increment counter for next student
    User.create(email: Faker::Internet.email, password: "password", role: "superadmin", name: Faker::Name.name)
    User.create(email: Faker::Internet.email, password: "password", role: "teacher", name: Faker::Name.name)

    # Teacher
    Whirly.status = LoadingMessages.get
    User.create(email: "santos@gmail.com", password: "password", role: "teacher", name: "Sir. Jayson Santos")
    User.create(email: "delfino@gmail.com", password: "password", role: "teacher", name: "Sir. Nico Ranelle Delfino")
    User.create(email: "pacionista@gmail.com", password: "password", role: "teacher", name: "Sir. Raymond Pacionista")
    User.create(email: "bation@gmail.com", password: "password", role: "teacher", name: "Sir. Albert Bation")
    User.create(email: "arevalo@gmail.com", password: "password", role: "teacher", name: "Sir. Michael Paul Arevalo")

    # Admin
    Whirly.status = LoadingMessages.get
    User.create(email: "martin@gmail.com", password: "password", role: "admin", name: "Jamesmar Martin")
    User.create(email: "roxas@gmail.com", password: "password", role: "admin", name: "Shello Roxas")
    
    # Classes
    Whirly.status = LoadingMessages.get
    @ict = SchoolClass.create(name: "ICT", description: "Information Communications Technology")
    @stem = SchoolClass.create(name: "STEM", description: "Science, Technology, Engineering, and Mathematics")
    @gas = SchoolClass.create(name: "GAS", description: "General Academic Strand")
    SchoolClass.create(name: "ABM", description: "Accountancy, Business, and Management")
    SchoolClass.create(name: "HUMSS", description: "Humanities and Social Sciences")
    
    # School Year
    Whirly.status = LoadingMessages.get
    @ict_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @ict.id)
    SchoolYear.create(name: "2024 - 2025", school_class_id: @ict.id)
    @stem_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @stem.id)
    @gas_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @gas.id)
    
    # Section
    Whirly.status = LoadingMessages.get
    @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - A")
    @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - B")
    @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "12 - A")

    Whirly.status = LoadingMessages.get
    @stem.school_years.find_by(id: @stem_sy.id).school_sections.create(name: "11 - A")
    @gas.school_years.find_by(id: @gas_sy.id).school_sections.create(name: "11 - B")

    # Period
    Whirly.status = LoadingMessages.get
    Quarter.create(name: "1st Grading Period")
    Quarter.create(name: "2nd Grading Period")
    Quarter.create(name: "3rd Grading Period")
    Quarter.create(name: "4th Grading Period")
    
end
Whirly.stop
puts "Seeding complete. Database has been populated with initial data."


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

if User.exists?
    puts "Seeding skipped: Database already contains data."
else
    Whirly.status = LoadingMessages.get
    PaperTrail.request(whodunnit: '[System Generated]') do
        User.create(email: "admin@example.com", password: "password", role: "superadmin", name: "Jameson Teodore")
        
        Whirly.status = LoadingMessages.get
        # Initialize a counter for student numbers
        student_counter = 1
        3.times do
            User.create(email: Faker::Internet.email, password: "password", role: "admin", name: Faker::Name.name)
            User.create(email: Faker::Internet.email, password: "password", role: "student", name: Faker::Name.name, student_number: format('%06d', student_counter))
            student_counter += 1  # Increment counter for next student
            User.create(email: Faker::Internet.email, password: "password", role: "superadmin", name: Faker::Name.name)
            User.create(email: Faker::Internet.email, password: "password", role: "teacher", name: Faker::Name.name)
        end
        
        Whirly.status = LoadingMessages.get
        @ict = SchoolClass.create(name: "ICT", description: "Information Communications Technology")
        @stem = SchoolClass.create(name: "STEM", description: "Science, Technology, Engineering, and Mathematics")
        @gas = SchoolClass.create(name: "GAS", description: "General Academic Strand")
        SchoolClass.create(name: "ABM", description: "Accountancy, Business, and Management")
        SchoolClass.create(name: "HUMSS", description: "Humanities and Social Sciences")
        
        Whirly.status = LoadingMessages.get
        @ict_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @ict.id)
        SchoolYear.create(name: "2024 - 2025", school_class_id: @ict.id)
        @stem_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @stem.id)
        @gas_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @gas.id)
        
        Whirly.status = LoadingMessages.get
        @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - A")
        @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - B")
        @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "12 - A")

        Whirly.status = LoadingMessages.get
        @stem.school_years.find_by(id: @stem_sy.id).school_sections.create(name: "11 - A")
        @gas.school_years.find_by(id: @gas_sy.id).school_sections.create(name: "11 - B")
        
    end
    Whirly.stop
    puts "Seeding complete. Database has been populated with initial data."
end

# HERES THE OLD SEEDING OF SCHOOL CLASS, YEAR, SECTION
# Whirly.status = LoadingMessages.get
        # @ict = SchoolClass.create(name: "ICT", description: "Information Communications Technology")
        # @stem = SchoolClass.create(name: "STEM", description: "Science, Technology, Engineering, and Mathematics")
        # @gas = SchoolClass.create(name: "GAS", description: "General Academic Strand")
        # SchoolClass.create(name: "ABM", description: "Accountancy, Business, and Management")
        # SchoolClass.create(name: "HUMSS", description: "Humanities and Social Sciences")
        
        # Whirly.status = LoadingMessages.get
        # @ict_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @ict.id)
        # SchoolYear.create(name: "2024 - 2025", school_class_id: @ict.id)
        # @stem_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @stem.id)
        # @gas_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @gas.id)
        
        # Whirly.status = LoadingMessages.get
        # @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - A")
        # @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "11 - B")
        # @ict.school_years.find_by(id: @ict_sy.id).school_sections.create(name: "12 - A")

        # Whirly.status = LoadingMessages.get
        # @stem.school_years.find_by(id: @stem_sy.id).school_sections.create(name: "11 - A")
        # @gas.school_years.find_by(id: @gas_sy.id).school_sections.create(name: "11 - B")

# HERES THE STABLE VERSION OF SEED BUT IT DOESNT STORE IN TABLE DATA
=begin
Whirly.status = LoadingMessages.get
        @ict = SchoolClass.create(name: "ICT", description: "Information Communications Technology")
        @stem = SchoolClass.create(name: "STEM", description: "Science, Technology, Engineering, and Mathematics")
        @gas = SchoolClass.create(name: "GAS", description: "General Academic Strand")
        SchoolClass.create(name: "ABM", description: "Accountancy, Business, and Management")
        SchoolClass.create(name: "HUMSS", description: "Humanities and Social Sciences")
        
        Whirly.status = LoadingMessages.get
        @ict_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @ict.id)
        SchoolYear.create(name: "2024 - 2025", school_class_id: @ict.id)
        @stem_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @stem.id)
        @gas_sy = SchoolYear.create(name: "2023 - 2024", school_class_id: @gas.id)
        
        Whirly.status = LoadingMessages.get

        # Ensure the school years are saved before creating sections
        if @ict_sy.persisted? # Check if @ict_sy is saved
        @ict_sy.school_sections.create(name: "11 - A")
        @ict_sy.school_sections.create(name: "11 - B")
        @ict_sy.school_sections.create(name: "12 - A")
        end

        if @stem_sy.persisted? # Check if @stem_sy is saved
        @stem_sy.school_sections.create(name: "11 - A")
        end

        if @gas_sy.persisted? # Check if @gas_sy is saved
        @gas_sy.school_sections.create(name: "11 - B")
        end
=end
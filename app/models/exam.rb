# frozen_string_literal: true

class Exam < ApplicationRecord
  include Exportable

  has_paper_trail

  validates :name, presence: true
  validates :subject, presence: true
  validates :items, presence: true
  validates :answer_key, presence: true

  belongs_to :subject
  belongs_to :quarter

  has_many :responses

  # ITEM ANALYSIS
   # Correct answer frequency
  def correct_frequency
    responses.where(answer: answer_key).count
  end

  # Incorrect answer frequency
  def incorrect_frequency
    responses.where.not(answer: answer_key).count
  end

  # Difficulty index calculation
  def difficulty_index
    total_responses = responses.count
    total_responses.zero? ? 0 : (correct_frequency.to_f / total_responses).round(2)
  end

  # Discrimination index calculation (example, you might use a custom formula)
  def discrimination_index
    # Example calculation; adjust this to match the desired formula
    high_group = responses.where('score >= ?', passing_score).count
    low_group = responses.where('score < ?', passing_score).count
    (high_group - low_group).to_f / responses.count
  end

  # RANSACK
  def self.ransackable_attributes(_auth_object = nil)
    %w[name updated_at]
  end

  # Allowlist associations for Ransack
  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def self.add_headers(csv, fields)
    csv << fields[:exams].map { |exam| "exam_#{exam}" }
  end

  def self.add_records(csv, fields)
    all.find_each do |record|
      csv << csv_row(fields, record)
    end
  end

  def self.to_csv(fields)
    headers = fields[:no_header].present?

    CSV.generate(headers:) do |csv|
      add_headers(csv, fields) unless headers
      add_records(csv, fields)
    end
  end

  def self.to_xml(fields)
    serial_data(fields).to_xml
  end

  def self.to_json(fields)
    serial_data(fields).to_json
  end

  def self.csv_row(fields, record)
    fields[:exams].map { |field| record.send(field) }
  end

  def self.serial_data(fields)
    all.map do |record|
      fields[:exams].index_with { |field| record.send(field) }
    end
  end
end

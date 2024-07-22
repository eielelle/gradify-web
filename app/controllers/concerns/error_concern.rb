# frozen_string_literal: true

module ErrorConcern
  extend ActiveSupport::Concern

  included do
  end

  private

  def handle_errors(model)
    model.errors.each do |error|
      flash["#{error.attribute}_error"] = "#{error.attribute.capitalize} #{model.errors[error.attribute].first}"
    end
  end
end

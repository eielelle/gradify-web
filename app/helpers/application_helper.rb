# frozen_string_literal: true

module ApplicationHelper
  def border_class(condition)
    condition ? 'border-b border-x' : ''
  end

  def current_drawer?(path)
    'bg-primary text-white rounded-lg' if current_page?(path)
  end
end

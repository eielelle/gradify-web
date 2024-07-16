# frozen_string_literal: true

module ApplicationHelper
  def border_class(condition)
    condition ? 'border-b border-x' : ''
  end

  def current_drawer?(path, included: false)
    if request.path.include?(path) && included
      'bg-primary text-white rounded-lg'
    elsif current_page?(path)
      'bg-primary text-white rounded-lg'
    end
  end
end

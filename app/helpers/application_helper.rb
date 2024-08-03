# frozen_string_literal: true

module ApplicationHelper
  def border_class(condition)
    condition ? 'border-b border-x' : ''
  end

  def current_drawer?(path, included: false)
    if request.path.include?(path) && included
      'border-r-8 border-primary'
    elsif current_page?(path)
      'border-r-8 border-primary'
    end
  end

  def format_date(date)
    return nil if date.blank?

    date.strftime('%B %d, %Y at %I:%M %p')
  end
end

# frozen_string_literal: true

module ApplicationHelper
    def border_class(condition)
        condition ? 'border-b border-x' : ''
    end
end

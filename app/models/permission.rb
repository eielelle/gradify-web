# frozen_string_literal: true

class Permission < ApplicationRecord
  include Exportable

  has_and_belongs_to_many :admins
end

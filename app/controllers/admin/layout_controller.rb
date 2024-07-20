# frozen_string_literal: true

module Admin
  class LayoutController < ApplicationController
    layout 'admin_panel'
    before_action :authenticate_admin_account!, :set_paper_trail_whodunnit
  end
end

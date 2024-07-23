# frozen_string_literal: true

module Admin
  class LayoutController < ApplicationController
    include HandleAccessDeniedConcern

    layout 'admin_panel'
    before_action :authenticate_admin_account!
    authorize_resource class: false

    # in ApplicationController
    def current_ability
      if current_admin_account.present?
        @current_ability ||= Ability.new(current_admin_account)
      else
        @current_ability ||= Ability.new(current_user)
      end
    end
  end
end

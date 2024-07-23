# frozen_string_literal: true

module Admin
  class LayoutController < ApplicationController
    include HandleAccessDeniedConcern

    layout 'admin_panel'
    before_action :authenticate_admin_account!
    authorize_resource class: false

    # in ApplicationController
    def current_ability
      @current_ability ||= if current_admin_account.present?
                             Ability.new(current_admin_account)
                           else
                             Ability.new(current_user)
                           end
    end
  end
end

# frozen_string_literal: true

module PaperTrailConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_paper_trail_whodunnit
  end

  private

  def user_for_paper_trail
    if current_admin_account
      current_admin_account.name
    else
      'Unknown'
    end
  end
end

# frozen_string_literal: true

module SnapshotConcern
  extend ActiveSupport::Concern

  included do
  end

  private

  def get_snapshot(version)
    if version.item.nil?
      if version.next.nil?
        version.reify
      else
        version.next.reify
      end
    else
      version.item.paper_trail.version_at(version.created_at)
    end
  end
end

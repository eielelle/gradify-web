# frozen_string_literal: true

module SuperAdminConcern
    extend ActiveSupport::Concern
  
    included do
    end
  
    private
  
    def superadmin_redirect(model, path, msg)
        is_superadmin = model.permission.name == 'SuperAdmin'
        
        if is_superadmin
          flash[:toast] = msg
          flash[:notice] = msg
          redirect_to path
        end
        
        is_superadmin
      end
  end
  
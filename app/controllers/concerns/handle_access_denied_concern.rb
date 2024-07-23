module HandleAccessDeniedConcern
    extend ActiveSupport::Concern
  
    included do
      rescue_from CanCan::AccessDenied do |exception|
        redirect_to access_denied_redirect_path, alert: exception.message
      end
    end
  
    private
  
    def access_denied_redirect_path
      root_path
    end
  end
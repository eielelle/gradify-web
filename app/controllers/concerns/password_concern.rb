# frozen_string_literal: true

# app/controllers/concerns/password_concern.rb
module PasswordConcern
  extend ActiveSupport::Concern

  def update_model_password(resource_class: nil, user: nil)
    resource = user.nil? ? find_resource(resource_class) : user
    if valid_password?(resource, resource_password_params[:current_password])
      update_password(resource) ? successful_update : failed_update(resource)
    else
      flash[:current_password_error] = 'Password is incorrect'
      redirect_to edit_password_path
    end
  end

  private

  def find_resource(resource_class)
    resource_class.find(params[:id])
  end

  def resource_password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  def valid_password?(resource, current_password)
    resource.valid_password?(current_password)
  end

  def update_password(resource)
    resource.update(resource_password_params.except(:current_password))
  end

  def successful_update
    flash[:toast] = 'Password updated successfully'
    redirect_to after_update_path
  end

  def failed_update(resource)
    handle_errors(resource)
    redirect_to edit_password_path
  end

  # Override these methods in the including controller if needed
  def edit_password_path
    raise NotImplementedError, "Define 'edit_password_path' in the including controller"
  end

  def after_update_path
    raise NotImplementedError, "Define 'after_update_path' in the including controller"
  end
end

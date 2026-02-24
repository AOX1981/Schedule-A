module Web
  class BusinessProfilesController < ApplicationController
    before_action :require_login
    before_action :set_profile, only: [:edit, :update, :destroy]

    def new
      @profile = current_user.business_profiles.build(tax_year: Date.current.year)
    end

    def create
      @profile = current_user.business_profiles.build(profile_params)
      if @profile.save
        AuditLog.log!(user: current_user, auditable: @profile, action: "create", ip_address: request.remote_ip)
        flash[:notice] = "Business profile created."
        redirect_to web_settings_path
      else
        flash.now[:alert] = "Please fix the errors below."
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      @profile.assign_attributes(profile_params)
      changed = @profile.changes
      if @profile.save
        AuditLog.log!(user: current_user, auditable: @profile, action: "update",
                      changed_fields: changed, ip_address: request.remote_ip)
        flash[:notice] = "Business profile updated."
        redirect_to web_settings_path
      else
        flash.now[:alert] = "Please fix the errors below."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      AuditLog.log!(user: current_user, auditable: @profile, action: "delete", ip_address: request.remote_ip)
      @profile.destroy!
      flash[:notice] = "Business profile deleted."
      redirect_to web_settings_path
    end

    private

    def set_profile
      @profile = current_user.business_profiles.find(params[:id])
    end

    def profile_params
      params.require(:business_profile).permit(:business_name, :ein, :business_type, :tax_year)
    end
  end
end

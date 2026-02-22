module Api
  module V1
    class BusinessProfilesController < BaseController
      before_action :set_business_profile, only: [:show, :update, :destroy]

      def index
        profiles = current_user.business_profiles.order(tax_year: :desc)
        render json: { business_profiles: BusinessProfileSerializer.new(profiles).to_h }
      end

      def show
        render json: { business_profile: BusinessProfileSerializer.new(@business_profile).to_h }
      end

      def create
        profile = current_user.business_profiles.build(business_profile_params)
        profile.save!
        AuditLog.log!(user: current_user, auditable: profile, action: "create", ip_address: client_ip)
        render json: { business_profile: BusinessProfileSerializer.new(profile).to_h }, status: :created
      end

      def update
        @business_profile.assign_attributes(business_profile_params)
        changed = @business_profile.changes
        @business_profile.save!
        AuditLog.log!(user: current_user, auditable: @business_profile, action: "update",
                      changed_fields: changed, ip_address: client_ip)
        render json: { business_profile: BusinessProfileSerializer.new(@business_profile).to_h }
      end

      def destroy
        AuditLog.log!(user: current_user, auditable: @business_profile, action: "delete", ip_address: client_ip)
        @business_profile.destroy!
        render json: { message: "Business profile deleted" }
      end

      private

      def set_business_profile
        @business_profile = current_user.business_profiles.find(params[:id])
      end

      def business_profile_params
        params.require(:business_profile).permit(:business_name, :ein, :business_type, :tax_year)
      end
    end
  end
end

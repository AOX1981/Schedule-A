module Web
  class SettingsController < ApplicationController
    before_action :require_login

    def show
      @profiles = current_user.business_profiles.order(tax_year: :desc)
      @accounts = current_user.accounts.order(:nickname)
    end
  end
end

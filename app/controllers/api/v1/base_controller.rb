module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable
      include Pagy::Method

      private

      def pagy_metadata(pagy)
        {
          current_page: pagy.page,
          per_page: pagy.limit,
          total_pages: pagy.pages,
          total_count: pagy.count
        }
      end
    end
  end
end

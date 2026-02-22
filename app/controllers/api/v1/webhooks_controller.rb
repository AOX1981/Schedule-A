module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def inbound_email
        sender = params[:from] || params[:sender]
        subject = params[:subject]
        body = params[:text] || params[:html]

        user = User.find_by(email: extract_email(sender))
        unless user
          render json: { code: "not_found", message: "No user found for sender email" }, status: :ok
          return
        end

        receipt = user.receipts.create!(
          source: "email_forward",
          designation: "business",
          status: "pending",
          store_name: subject
        )

        if params[:attachments].present?
          Array(params[:attachments]).each do |attachment|
            receipt.image.attach(attachment)
          end
        end

        ReceiptExtractionJob.perform_later(receipt.id) if receipt.image.attached?

        render json: { message: "Receipt created from email", receipt_id: receipt.id }, status: :created
      end

      private

      def extract_email(from_string)
        return nil if from_string.blank?
        match = from_string.match(/<(.+?)>/)
        match ? match[1].downcase : from_string.strip.downcase
      end
    end
  end
end

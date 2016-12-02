module Api
  module V1
    class SubscriptionsController < Api::V1::BaseApiController
      include SubscriptionsDoc

      # Subscribe
      def create
        @collection, @url = params[:collection], params[:url]
        (render_parameters_missing and return) if @url.blank? || @collection.blank?
        begin
          s = Subscription.new
          s.api_key = @key
          s.collection = @collection
          s.url = @url
          s.save!
        rescue
          render_unknown_error
        end
        render_success
      end

      # Unsubscribe
      def destroy
        @collection, @url = params[:collection], params[:url]
        (render_parameters_missing and return) if @url.blank? || @collection.blank?
        s = Subscription.where(api_key_id: @key.id, collection: @collection, url: @url).last
        if s.nil?
          render_not_found
        else
          s.destroy
          render_success
        end
      end
    end
  end
end

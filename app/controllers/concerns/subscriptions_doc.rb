#encoding: utf-8
# :nocov:
module SubscriptionsDoc
  extend ActiveSupport::Concern

  included do
    swagger_controller :subscriptions, 'Subscriptions'

    swagger_api :create do
      summary 'Subscribe to a collection'
      notes 'Subscribe to a collection'
      param :query, :url, :string, :required, 'URL that owns the collection'
      param :query, :collection, :string, :required, 'Collection name'
      response :ok, 'Subscribed successfully'
      response 400, 'Parameters missing'
      response 401, 'Access denied'
    end

    swagger_api :destroy do
      summary 'Unsubscribe from a collection'
      notes 'Unsubscribe from a collection'
      param :query, :url, :string, :required, 'URL that owns the collection'
      param :query, :collection, :string, :required, 'Collection name'
      response :ok, 'Unsubscribed successfully'
      response 400, 'Parameters missing'
      response 401, 'Access denied'
      response 404, 'Subscription not found'
    end
  end
end
# :nocov:

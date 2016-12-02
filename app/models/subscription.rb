class Subscription < ActiveRecord::Base
  belongs_to :api_key
  validates_uniqueness_of :collection, scope: [:api_key_id, :url]
end 

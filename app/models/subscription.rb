class Subscription < ActiveRecord::Base
  belongs_to :api_key
  validates_uniqueness_of :collection, scope: [:api_key_id, :url]

  def stream
    media = Media.new(url: self.url)
    data = media.as_json
    stream_method = "stream_from_#{data['provider']}_#{data['type']}"
    media.send(stream_method, self.collection) do |item|
      yield(item)
    end
  end
end 

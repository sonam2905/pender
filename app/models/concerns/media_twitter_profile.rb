require 'pender_exceptions'

module MediaTwitterProfile
  extend ActiveSupport::Concern

  included do
    Media.declare('twitter_profile', [/^https?:\/\/(www\.)?twitter\.com\/([^\/]+)$/])
  end

  def stream_from_twitter_profile(collection)
    if collection == 'timeline'
      TweetStream::Client.new.follow(self.as_json['id'].to_s) do |status|
        tweet = Media.new(url: "#{self.url}/status/#{status.id}")
        tweet.data_from_twitter_item(status)
        yield({ collection: 'timeline', data: tweet.as_json }.to_json)
      end
    end
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = CONFIG['twitter_consumer_key']
      config.consumer_secret     = CONFIG['twitter_consumer_secret']
      config.access_token        = CONFIG['twitter_access_token'] 
      config.access_token_secret = CONFIG['twitter_access_token_secret']
    end
  end

  def data_from_twitter_profile
    username = self.data[:username] = self.get_twitter_username

    handle_twitter_exceptions do
      self.data.merge!(self.twitter_client.user(username).as_json)
    end

    self.process_twitter_profile_images

    self.data.merge!({
      title: self.data['name'],
      picture: self.data[:pictures][:original],
      published_at: self.data['created_at'],
      collections: { timeline: {} }
    })
  end
  
  def process_twitter_profile_images
    picture = self.data['profile_image_url_https'].to_s
    self.data[:pictures] = {
      normal: picture,
      bigger: picture.gsub('_normal', '_bigger'),
      mini: picture.gsub('_normal', '_mini'),
      original: picture.gsub('_normal', '')
    }
  end

  def get_twitter_username
    self.url.match(/^https?:\/\/(www\.)?twitter\.com\/([^\/]+)$/)[2]
  end
end

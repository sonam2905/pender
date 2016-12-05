class ApiKey < ActiveRecord::Base
  validates_presence_of :access_token, :expire_at
  validates_uniqueness_of :access_token

  before_validation :generate_access_token, on: :create
  before_validation :calculate_expiration_date, on: :create
  
  attr_accessible :application
  attr_accessor :stream_item_id

  has_many :subscriptions

  # Reimplement this method in your application
  def self.applications
    [nil]
  end
  
  validates :application, inclusion: { in: proc { ApiKey.applications } }

  def stream
    channels = {}
    self.subscriptions.each do |subscription|
      channel = "pender.subscription.#{subscription.id}"
      channels[channel] = subscription
    end

    ticker = Thread.new { loop { sleep 5 } }
    sender = Thread.new do
      redis_client = Redis.new host: CONFIG['redis_host '], port: CONFIG['redis_port'], db: CONFIG['redis_db'], timeout: 2
      redis_client.subscribe(channels.keys) do |on|
        on.subscribe do |channel, subscriptions|
          puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
        end

        on.message do |subscription, data|
          yield({ collection: channels[subscription].collection, data: data }.to_json)
        end
      end
    end
    ticker.join
    sender.join
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless ApiKey.where(access_token: access_token).exists?
    end
  end

  def calculate_expiration_date
    self.expire_at = Time.now.since(30.days)
  end
end

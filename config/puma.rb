plugin 'tmp_restart'

TweetStream.configure do |config|
  config.consumer_key       = CONFIG['twitter_consumer_key']
  config.consumer_secret    = CONFIG['twitter_consumer_secret']
  config.oauth_token        = CONFIG['twitter_access_token'] 
  config.oauth_token_secret = CONFIG['twitter_access_token_secret']
  config.auth_method        = :oauth
end

puts "Starting Twitter stream..."

uids = {}
SUBSCRIPTIONS.each do |obj|
  media = obj[:media]
  subscription = obj[:subscription]
  if media['type'] == 'profile' && media['provider'] == 'twitter' && subscription.collection == 'timeline'
    id = media['id'].to_i
    uids[id] ||= []
    uids[id] << subscription
  end
end

puts "Tracking Twitter user ids: #{uids.keys}..."

TWITTER_STREAM = TweetStream::Client.new

redis_client = Redis.new host: CONFIG['redis_host '], port: CONFIG['redis_port'], db: CONFIG['redis_db'], timeout: 2

Thread.start {
  TWITTER_STREAM.on_error do |message|
    puts "Error from Twitter: #{message}"
  end.follow(uids.keys) do |status|
    puts "Got tweet with id #{status.id}..."
    subscription = uids[status.user.id].first
    tweet = Media.new(url: "#{subscription.url}/status/#{status.id}")
    json = tweet.as_json({}, status)
    puts "Stored tweet with id #{status.id}!"
  
    redis_client.publish("pender.subscription.#{subscription.id}", json)
  end
}

on_worker_shutdown do
  puts "Stopping Twitter stream..."
  TWITTER_STREAM.stop
  puts "Quitting Redis..."
  REDIS_CLIENT.quit
end

SUBSCRIPTIONS = []
Subscription.all.each do |subscription|
  media = Media.new(url: subscription[:url])
  SUBSCRIPTIONS << { subscription: subscription, media: media.as_json }
end

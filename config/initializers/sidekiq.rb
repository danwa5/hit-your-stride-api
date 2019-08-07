redis_opts = { :url => ENV['REDIS_URL'] }

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end

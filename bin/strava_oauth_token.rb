#!/usr/bin/env ruby

require 'dotenv/load'
require_relative '../lib/strava/oauth/client'
require 'webrick'

server = WEBrick::HTTPServer.new(Port: 3002)

client = Strava::OAuth::Client.new

server.mount_proc '/' do |req, res|
  code = req.query['code']
  response = client.oauth_token(code: code).parsed_response

  puts response

  res.body = %(
<html>
  <body>
    <ul>
      <li>token_type: #{response.fetch('token_type', '')}</li>
      <li>refresh_token: #{response.fetch('refresh_token')}</li>
      <li>access_token: #{response.fetch('access_token')}</li>
      <li>expires_at: #{response.fetch('expires_at')}</li>
    </ul>
  <body>
</html>
  )

  server.shutdown
end

redirect_url = client.authorize_url

server.logger.info "opening browser at #{redirect_url}\n"
system 'open', redirect_url

server.start

# Script used to generatee a valid connexion token will using ToM WS
# Output a connexion token
require 'Digest'

def ws_generate_api_token(api_key, application_id)
  puts "Generating connexion token for application #{application_id}, using API key #{api_key}"

  timestamp = Time.now.getutc.to_i
  apiKey = api_key + timestamp.to_s + application_id
  hash = Digest::SHA256.new << apiKey

  puts "X-TOM-APP : " + application_id
  puts "X-TOM-RTS : " + timestamp.to_s
  puts "X-TOM-API-HASH : " + hash.to_s
end 

if (__FILE__) == $0
  if ARGV.count != 2
    puts "Usage : #{$0} apiKey application_id"
    exit
  end

  # Generate token
  ws_generate_api_token(ARGV[0], ARGV[1])
end


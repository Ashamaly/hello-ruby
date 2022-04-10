require 'ldclient-rb'
require 'uri'
require 'net/http'

#Webhook URL (place PagerDuty url here)
url = URI("http://mockbin.org/bin/3aa39162-abf5-4aad-84e1-319b1b348871?foo=bar&foo=baz")
http = Net::HTTP.new(url.host, url.port)
# Set sdk_key to your LaunchDarkly SDK key before running
sdk_key = "sdk-4e3a22d5-806a-4b5d-b0bc-72f00bf0403d"

# Set feature_flag_key to the feature flag key you want to evaluate
feature_flag_key = "siteMaintenance"

def show_message(s)
  puts "*** #{s}"
  puts
end

if sdk_key == ""
  show_message "Please edit main.rb to set sdk_key to your LaunchDarkly SDK key first"
  exit 1
end

client = LaunchDarkly::LDClient.new(sdk_key)

if client.initialized?
  show_message "SDK successfully initialized!"
else
  show_message "SDK failed to initialize"
  exit 1
end

# Set up the user properties. This user should appear on your LaunchDarkly users dashboard
# soon after you run the demo.
user = {
  key: "onCall",
  name: "ResponseManager"
}

flag_value = client.variation(feature_flag_key, user, false)

if flag_value
  #Site is up and working as expected
  show_message "Feature flag '#{feature_flag_key}' is #{flag_value} for this user"
else
  #Site has gone down and content has changed
  show_message "Site is under Maintenance"
  #Use webhook here to send a message to the on call manager
  request = Net::HTTP::Post.new(url)
  request["cookie"] = 'foo=bar; bar=baz'
  request.body = "foo=bar&bar=baz"

  response = http.request(request)
  show_message "#{response.read_body} "
end




# Here we ensure that the SDK shuts down cleanly and has a chance to deliver analytics
# events to LaunchDarkly before the program exits. If analytics events are not delivered,
# the user properties and flag usage statistics will not appear on your dashboard. In a
# normal long-running application, the SDK would continue running and events would be
# delivered automatically in the background.
client.close()

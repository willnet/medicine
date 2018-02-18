require 'line/bot'

message = {
  type: 'text',
  text: '薬のんだ？'
}

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

response = client.push_message("<to>", message)
p response

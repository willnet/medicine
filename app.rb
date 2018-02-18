require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  p events
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        replyable = %w(おけ うん のんだ 飲んだ のみました 飲みました).any? do |message|
          event.message['text'].match? message
        end

        message_text = if replyable
          'えらいね！'
        else
          'どうしたの'
        end
        message = {
          type: 'text',
          text: message_text
        }

        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        message = {
          type: 'text',
          text: 'どしたの'
        }

        client.reply_message(event['replyToken'], message)
      end
    end
  }

  "OK"
end

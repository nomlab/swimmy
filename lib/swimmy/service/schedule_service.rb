# coding: utf-8

require 'sheetq'
require 'json'
require 'uri'
require 'net/https'

module Swimmy
  module Service
    class Schedule
      def initialize(spreadsheet, google_oauth)
        @sheet = spreadsheet.sheet("calendar2", Swimmy::Resource::Calendar)
        @google_oauth = google_oauth
      end

      def add_event(event_info)
        calendar_name = event_info[:calendar_name]
        event_name = event_info[:event_name]
        start_time = event_info[:start_time]
        end_time = event_info[:end_time]
        calendars = @sheet.fetch
        calendar_id = nil
        calendars.each do |calendar|
          if calendar.name == calendar_name
            calendar_id = calendar.id
          end
        end
        if calendar_id.nil?
          return "#{calendar_name}というカレンダーが見つかりませんでした\nカレンダー名が正しいかどうか確認してください\n"
        end

        # make event data
        event = {
          summary: event_name,
          start: {
            dateTime: start_time.iso8601,
            timeZone: 'Asia/Tokyo'
          },
          end: {
            dateTime: end_time.iso8601,
            timeZone: 'Asia/Tokyo'
          }
        }
        # Google Calendar API Endpoint URL
        uri = URI.parse("https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events")

        # make HTTP request
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true  # HTTPS

        # POST request
        request = Net::HTTP::Post.new(uri.path, {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@google_oauth.token}"  # OAuth2.0 token
        })

        # set event data
        request.body = event.to_json

        # send request
        response = http.request(request)

        # check response
        if response.is_a?(Net::HTTPSuccess)
          event_data = JSON.parse(response.body)

          msg = <<~TEXT
            #{calendar_name}に以下の予定を追加しました

            イベント名: #{event_name}
            開始: #{start_time.year}年#{start_time.month}月#{start_time.day}日#{start_time.hour}:#{start_time.min.to_s.rjust(2, '0')}
            終了: #{end_time.year}年#{end_time.month}月#{end_time.day}日#{end_time.hour}:#{end_time.min.to_s.rjust(2, '0')}
          TEXT

          return msg
        else
          return "Failed to add event. Error: #{response.body}"
        end
      end
    end # class Schedule
  end # module Service
end # module Swimmy

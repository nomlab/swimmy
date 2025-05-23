# coding: utf-8

module Swimmy
  module Command
    class Schedule < Swimmy::Command::Base

      command "calendar" do |client, data, match|
        google_oauth ||= begin
          Swimmy::Resource::GoogleOAuth.new('config/credentials.json', 'config/tokens.json')
        rescue => e
          msg = 'Google OAuthの認証に失敗しました．適切な認証情報が設定されているか確認してください．'
          client.say(channel: data.channel, text: msg)
          return
        end
        calendar_resource = Swimmy::Resource::Schedule.new
        calendar_service = Swimmy::Service::Schedule.new(spreadsheet, google_oauth)

        if match[:expression]
          client.say(channel: data.channel, text: "予定を追加中...")
          # split arguments
          arg = match[:expression].split(" ")
          # parse arguments
          valid_arg, event_info, msg = calendar_resource.build_event_info(arg)
          if valid_arg
            # add events
            msg = calendar_service.add_event(event_info)
          end
        else
          # no arguments
          # help message
          msg = <<~TEXT
            calendar <カレンダー名> <予定名> <開始時刻> <終了時刻> - 指定されたカレンダーに予定を追加します
            開始・終了時刻の形式は以下のいずれかであり，統一される必要があります
            1. 時間のみ - 例: "10:00"
            2. 日/時間 - 例: "18/10:00"
            3. 月/日/時間 - 例: "4/18/10:00"
            4. 年/月/日/時間 - 例: "2023/4/18/10:00"
          TEXT
        end
        client.say(text: msg, channel: data.channel)
      end
    end # class Schedule
  end # module Command
end # module Swimmy

module Swimmy
  module Command
    class Location < Swimmy::Command::Base
      command 'loc' do |client, data, match|
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id
        user_name = user.profile.display_name
        location_prefix = match[:expression]

        if user_name == "nom"
          locations = {
                        "hi"         => "在室",
                        "meeting"    => "オンライン講義・会議中",
                        "laboratory" => "研究室(105・106)",
                        "lecture"    => "講義室",
                        "department" => "学科内",
                        "campus"     => "大学内",
                        "bye"        => "帰宅・出張"
                      }
        else
          locations = {
                        "hi"      => "在室",
                        "lecture" => "講義",
                        "meeting" => "打合",
                        "campus"  => "学内",
                        "outside" => "学外", 
                        "bye"     => "帰宅"
                    }
        end
        user_locations = Swimmy::Command::Location::UserLocationSelector.new(locations)

        if location_prefix.nil? || location_prefix.empty?
          client.say(channel: data.channel,
                        text: "引数が指定されていません．\n" +
                               user_locations.message_location_help)
          return
        end

        match_locations = user_locations.select_locations_by_prefix(location_prefix)

        if match_locations.length == 1
          begin
            doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
            doorplate_service.send_attendance_event(match_locations.values.first, user_name)
          rescue => e
            client.say(channel: data.channel, text: "ドアプレートの状態を更新できませんでした．")
            return
          end
          message = "ドアプレートの状態を #{match_locations.values.first} に更新しました．"
        elsif match_locations.length > 1
          message = "指定された文字列に該当する所在が複数見つかりました．\n" +
          		      user_locations.message_location_help
        elsif match_locations.length < 1
          message = "指定された文字列に該当する所在は見つかりませんでした．\n" +
          		      user_locations.message_location_help
        end
        client.say(channel: data.channel, text: message)
      end

      help do
        title "loc"
        desc "ドアプレートの所在を変更します．"
        long_desc <<~"TEXT"
                    loc <所在>
                    ドアプレートの状態を指定した<所在>に変更します．
                    指定できる<所在>は以下のいずれかです．\n
                    106号室
                    在室: hi
                    講義: lecture
                    打合: meeting
                    学内: campus
                    学外: outside
                    帰宅: bye\n
                    206号室
                    在室: hi
                    オンライン講義・会議中: meeting
                    研究室(105・106): laboratory
                    講義室: lecture
                    学科内: department
                    大学内: campus
                    帰宅・出張: bye\n
                    以下は，所在を"講義"に変更する場合の入力例です．
                    swimmy loc lecture\n
                    また，引数には省略形を指定することができます．
                    ただし，省略形は，他の候補と一意に識別可能な文字列に限ります．
                    以下は，引数に省略形を指定した場合の入力例です．
                    swimmy loc l
                    swimmy loc lec
                  TEXT
      end # help

      ###################################################################
      # private inner class

      class UserLocationSelector
        def initialize(locations)
          @locations = locations
        end # def initialize
        
        def select_locations_by_prefix(location_prefix)
          @locations.select { |key, _| key.start_with?(location_prefix) }
        end # def select_locations_by_prefix

        def message_location_help
          message = "引数を以下から1つ指定してください．\n\n" +
                    "所在 :  引数\n"

          @locations.each do |key, value|
            message << "#{value} :  #{key}\n"
          end

          message << <<~TEXT
            \n以下は，所在を"講義"に変更する場合の入力例です．
            "swimmy loc lecture"\n
            また，引数には省略形を指定することができます．
            ただし，省略形は，他の候補と一意に識別可能な文字列に限ります．
            以下は，引数に省略形を指定した場合の入力例です．
            "swimmy loc l"
            "swimmy loc lec"
          TEXT
          return message
        end # def message_location_help

      end # class UserLocationSelector
    end # class Location
  end # module Command
end # module Swimmy

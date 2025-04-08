module Swimmy
  module Command
    class Location < Swimmy::Command::Base
      command 'loc' do |client, data, match|
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id
        user_name = user.profile.display_name
        prefix = match[:expression]

        user_location_info = Swimmy::Resource::UserLocation.new(user_name, prefix)

        if user_location_info.prefix.nil? || user_location_info.prefix.empty?
          client.say(channel: data.channel,
                        text: "引数が指定されていません．\n" +
                              user_location_info.message_location_help)
          return
        end

        prefix_match_list = user_location_info.retrieve_complement_location_list

        # 引数で指定した文字列から始まる所在の数を判定
        if prefix_match_list.length > 1
          # 引数で指定した文字列が複数の所在にマッチする場合
          client.say(channel: data.channel,
                        text: "指定された文字列に該当する所在が複数見つかりました．\n" +
                              user_location_info.message_location_help)
          return
        elsif prefix_match_list.length == 0
          # 引数で指定した文字列が所在にマッチしない場合
          client.say(channel: data.channel,
                        text: "指定された文字列に該当する所在は見つかりませんでした．\n" +
                              user_location_info.message_location_help)
          return
        else
          # 引数で指定した文字列が1つの所在にマッチする場合
          begin
            doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
            doorplate_service.send_attendance_event(prefix_match_list.keys.first, user_id, user_name)
          rescue Exception => e
            client.say(channel: data.channel, text: "ドアプレートの状態を更新できませんでした．")
            raise e
          end
          client.say(channel: data.channel, text: "ドアプレートの状態を #{prefix_match_list.values.first} に更新しました．")
        end
      end

      help do
        title "location"
        desc "ドアプレートの所在を変更します．"
        long_desc "location <所在>\n" +
                  "ドアプレートの状態を指定した<所在>に変更します．\n" +
                  "指定できる<所在>は以下のいずれかです．\n\n" +
                  "106号室\n" +
                  "hi (h) : 在室\n" +
                  "lecture (l) : 講義\n" +
                  "meeting (m) : 打合\n" +
                  "campus (c) : 学内\n" +
                  "outside (o) : 学外\n" +
                  "bye (b) : 帰宅\n\n" +
                  +
                  "206号室\n" +
                  "hi (h) : 在室\n" +
                  "meeting (m) : オンライン講義・会議中\n" +
                  "laboratory (la) : 研究室(105・106)\n" +
                  "lecture (le) : 講義室\n" +
                  "department (d) : 学科内\n" +
                  "campus (c) : 大学内\n" +
                  "bye (b) : 帰宅・出張\n"
      end
    end
  end
end

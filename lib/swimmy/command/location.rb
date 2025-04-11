# hi         在室
# lec        講義
# meet       打合
# oncampus   学内
# offcampus  学外
# bye        帰宅

module Swimmy
  module Command
    class Location < Swimmy::Command::Base
      # command 'hi', 'lec', 'meet', 'on', 'off', 'bye' do |client, data, match|
      command 'location' do |client, data, match|
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id
        user_name = user.profile.display_name
        location_list = ["hi", "lec", "meet", "oncampus", "offcampus", "bye"]
        arg = match[:expression] # arg.class=>string

        # 引数が指定される場合
        if arg
          # 引数が正しい場合
          if location_list.include?(arg)
            # client.say(channel: data.channel, text:"arg: #{arg}")
          # 引数の数が正しくない場合
          elsif arg.split.length != 1
            client.say(channel: data.channel, text: "引数の数が正しくありません．")
            return;
          # 引数に誤った入力がされた場合
          else 
            client.say(channel: data.channel, text: "引数の値が正しくありません．")
            return;
          end
        # 引数が指定されない場合
        else 
          client.say(channel: data.channel, text: "引数の数が正しくありません．")
          return;
        end

        begin
          # 現在地をMQTTでpublish
          # client.say(channel: data.channel, text: "更新確認")
          doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
          doorplate_service.send_attendance_event(arg, user_id, user_name)
        rescue Exception => e
          client.say(channel: data.channel, text: "ドアプレートを更新できませんでした．")
          raise e
        end

        client.say(channel: data.channel, text: "ドアプレートを更新しました．")
      end

      # help do

      # end
    end
  end
end

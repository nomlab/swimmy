module Swimmy
  module Command
    class Location < Swimmy::Command::Base
      # command 'hi', 'lec', 'meet', 'on', 'off', 'bye' do |client, data, match|
      command 'location' do |client, data, match|
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id
        user_name = user.profile.display_name
        arg = match[:expression] # arg.class=>string
        
        # 部屋番号によって指定できる所在を変更する
        # 他の実装は可能?
        location_list_106 = ["hi", "lec", "meet", "campus", "outside", "bye"]
        location_list_206 = ["hi", "meet", "lab", "lec", "dept", "campus", "miss", "bye"]
        case user_name
        when "nom"
          location_list = location_list_206
        else
          location_list = location_list_106
        end

        
        if arg && location_list.include?(arg)
          # 引数が正しく指定される場合
          begin
            # MQTTブローカにpublish
            doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
            doorplate_service.send_attendance_event(arg, user_id, user_name)
          rescue Exception => e
            client.say(channel: data.channel, text: "ドアプレートを更新できませんでした．")
            raise e
          end
          client.say(channel: data.channel, text: "ドアプレートを更新しました．")
        else
          # 引数が正しく入力されない場合(値が不正，引数がない，引数が2つ以上) 
          say_wrong_arg(client, data)
          break;
        end
      end

      help do
        title "location"
        desc "ドアプレートの状態を変更します．"
        long_desc "location <所在>\n" +
                  "ドアプレートの状態を指定した<所在>に変更します．\n" +
                  "指定できる<所在>は以下のいずれかです．\n\n" +
                  "106号室\n" +
                  "hi :                   在室\n" +
                  "lec :                 講義\n" +
                  "meet :             打合\n" +
                  "campus :        学内\n" +
                  "outside :        学外\n" +
                  "bye :                帰宅\n\n" +
                  +
                  "206号室\n" +
                  "hi :                   在室\n" +
                  "meet :            オンライン講義・会議中\n" +
                  "lab :                 研究室(105・106)\n" +
                  "lec :                 講義室\n" +
                  "dept :              学科内\n" +
                  "campus :        大学内\n" +
                  "miss :              行方不明\n" +
                  "bye :                帰宅・出張\n" +
                  "\n引数は1つだけ指定してください．\n" # 出力のインデント調整のために空白を入れています
      end


      def self.say_wrong_arg(client, data)
        client.say(channel: data.channel,
                  text: "引数が正しく入力されていません．\n" +
                        "引数は 以下から1つだけ指定してください．\n\n" +
                        "106号室\n" +
                        "hi :                   在室\n" +
                        "lec :                 講義\n" +
                        "meet :             打合\n" +
                        "campus :        学内\n" +
                        "outside :        学外\n" +
                        "bye :                帰宅\n\n" +
                        +
                        "206号室\n" +
                        "hi :                   在室\n" +
                        "meet :            オンライン講義・会議中\n" +
                        "lab :                 研究室(105・106)\n" +
                        "lec :                 講義室\n" +
                        "dept :              学科内\n" +
                        "campus :        大学内\n" +
                        "miss :              行方不明\n" +
                        "bye :                帰宅・出張\n" # 出力のインデント調整のために空白を入れています
        )
      end
    end
  end
end

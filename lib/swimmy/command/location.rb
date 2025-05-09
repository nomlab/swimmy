module Swimmy
  module Command
    class Location < Swimmy::Command::Base
      command 'loc' do |client, data, match|
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id
        user_name = user.profile.display_name
        arg = match[:expression]

        # 所在リストを選択する
        location_list_106 = {
                              "hi"      => "在室",
                              "lecture" => "講義",
                              "meeting" => "打合",
                              "campus"  => "学内",
                              "outside" => "学外", 
                              "bye"     => "帰宅"
                            }
        location_list_206 = {
                              "hi"         => "在室",
                              "meeting"    => "オンライン講義・会議中",
                              "laboratory" => "研究室(105・106)",
                              "lecture"    => "講義室",
                              "departmemt" => "学科内",
                              "campus"     => "大学内",
                              "bye"        => "帰宅・出張"
                            }
        case user_name
        when "nom"
          location_list = location_list_206
        else
          location_list = location_list_106
        end

        # 引数が指定されていない場合
        if arg.nil? || arg.empty?
          client.say(channel: data.channel,
                        text: "引数が指定されていません．\n" +
                              message_location_help(location_list))
          return
        end

        # 引数の先頭が一致する所在を取得する
        prefix_match_list = retrieve_complement_location_list(arg, location_list)

        # 引数で指定した文字列から始まる所在の数を判定
        if prefix_match_list.length > 1
          # 引数で指定した文字列が複数の所在にマッチする場合
          client.say(channel: data.channel,
                        text: "指定された文字列に該当する所在が複数見つかりました．\n" +
                              message_location_help(location_list)) 
          # min_prefix_list = get_min_prefix_list(prefix_match_list.keys)
          # prefix_match_list.each do |key, value|
          #   client.say(channel: data.channel,
          #                 text: "#{key}, #{value}, #{min_prefix_list[key]}")
          # end
          return
        elsif prefix_match_list.length == 0
          # 引数で指定した文字列が所在にマッチしない場合
          client.say(channel: data.channel,
                        text: "指定された文字列に該当する所在は見つかりませんでした．\n" +
                              message_location_help(location_list))
          return
        end

        # 引数で指定した文字列が1つの所在にマッチする場合
        begin
          # MQTTブローカにpublish
          doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
          doorplate_service.send_attendance_event(prefix_match_list.keys.first, user_id, user_name)
        rescue Exception => e
          client.say(channel: data.channel, text: "ドアプレートを更新できませんでした．")
          raise e
        end
        client.say(channel: data.channel, text: "ドアプレートを更新しました．")
      end

      ################################################################################
      # TODO: help, self_say.wrong_arg の内容を変更する
      help do
        title "location"
        desc "ドアプレートの状態を変更します．"
        long_desc "location <所在>\n" +
                  "ドアプレートの状態を指定した<所在>に変更します．\n" +
                  "指定できる<所在>は以下のいずれかです．\n\n" +
                  "106号室\n" +
                  "hi :                   在室\n" +
                  "lecture :                 講義\n" +
                  "meeting :             打合\n" +
                  "campus :        学内\n" +
                  "outside :        学外\n" +
                  "bye :                帰宅\n\n" +
                  +
                  "206号室\n" +
                  "hi :                   在室\n" +
                  "meeting :            オンライン講義・会議中\n" +
                  "laboratory :                 研究室(105・106)\n" +
                  "lecture :                 講義室\n" +
                  "department :              学科内\n" +
                  "campus :        大学内\n" +
                  "bye :                帰宅・出張\n" +
                  "\n引数は1つだけ指定してください．\n" # 出力のインデント調整のために空白を入れています
      end

      ################################################################################
      # Helper Functions
      
      # 引数に関するヘルプ文を取得
      def self.message_location_help(location_list)
        # プレフィックスリストを作成
        prefix_list = get_min_prefix_list(location_list.keys)

        max_location_len = get_max_len(location_list.keys)
        max_state_len = get_max_len(location_list.values)
        max_prefix_len = get_max_len(prefix_list.values)

        # TODO: puts -> client.say
        message = "引数を以下から1つを指定してください．\n\n" +
                  "引数(最小入力) : 所在名\n"
  
        location_list.each do |key, value|
          message += "#{key.ljust(max_location_len)} (#{prefix_list[key].ljust(max_prefix_len)}) : #{value.ljust(max_state_len)}\n" 
        end
        return message
      end

      # 所在リストから prefix で始まる所在を取得する
      def self.retrieve_complement_location_list(prefix, location_list)
        prefix_match_list = Hash::new
        location_list.each do |key, value|
          if key.start_with?(prefix) 
            prefix_match_list[key] = value
          end
        end
        return prefix_match_list
      end

      # 各 key を一意に識別できる最小の prefix を取得する
      def self.get_min_prefix_list(location_keys)
        result = Hash::new
  
        location_keys.each do |key|
          min_prefix = key
          others = location_keys.each.reject { |k| k == key }  # 自分以外にこの prefix から始まるものがあるかチェック
          (1..key.length).each do |prefix_len|
            prefix = key[0, prefix_len]
            conflict = others.any? { |k| k.start_with?(prefix) }  # プレフィックスの衝突判定
      
            # 衝突が発生しなければリストに追加し終了
            unless conflict
              min_prefix = prefix
              break
            end
          end
          result[key] = min_prefix
        end
        return result
      end

    end
  end
end

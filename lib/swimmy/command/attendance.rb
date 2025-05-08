# coding: utf-8
#
# Keep track of members' attendance
#
module Swimmy
  module Command
    class Attendance < Swimmy::Command::Base
      command 'hi', 'bye' do |client, data, match|

        cmd = match[:command]
        now = Time.now

        # if no argument
        if !match[:expression]
          user = client.web_client.users_info(user: data.user).user
          user_id = user.id
          user_name = user.profile.display_name

        # if with argument
        else
          args = match[:expression].split
          # if with one argument
          if args.length == 1
            # fetch active members from nompedia
            active_members = spreadsheet.sheet("members", Swimmy::Resource::Member).fetch.select {|m| m.active? }.map {|m| m.account }

            # judge if the person specified in the argument is active
            if active_members.include?(args[0])
              user = client.web_client.users_info(user: data.user).user
              user_id = user.id
              user_name = args[0]
            else
              # if not active, print error message
              msg = "ユーザ #{args[0]}は現役メンバではありません．"
              client.say(channel: data.channel, text: msg)
              next
            end
          # if with two or more arguments, print error message
          elsif args.length >= 2
            msg = "引数は1つしか設定できません．\n"
            client.say(channel: data.channel, text: msg)
            next
          end
        end

        # log to spreadsheet
        now_s = now.strftime("%Y-%m-%d %H:%M:%S")
        client.say(channel: data.channel,
                   text: "記録中: #{now_s} #{cmd} #{user_name}...")
        begin
          logger = Swimmy::Service::AttendanceLogger.new(spreadsheet)
          logger.log(now, cmd, user_name, "")
        rescue Exception => e
          client.say(channel: data.channel, text: "履歴を記録できませんでした.")
          raise e
        end

        client.say(channel: data.channel, text: "履歴を記録しました．")

        # attendance event (for doorplate)
        doorplate_service = Swimmy::Service::Doorplate.new(mqtt_client)
        doorplate_service.send_attendance_event(cmd, user_id, user_name)
      end

      help do
        title "attendance"
        desc "hi/bye で入退室をスプレッドシートに記録し，ドアプレートを更新します"
        long_desc "attendance (hi|bye)\n" +
                  "もしくは，メンションで hi/bye だけでも OK です．\n" +
                  "attendance (hi|bye) [MEMBER]\n" +
                  "[MEMBER] を指定して，attendance コマンドを実行します"
      end
    end # class Attendance
  end # module Command
end # module Swimmy

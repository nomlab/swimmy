# coding: utf-8
#
# Keep track of members' attendance
#
module Swimmy
  module Command
    class Attendance < Swimmy::Command::Base
      command 'hi', 'bye' do |client, data, match|

        cmd = match[:command]
        arg = match[:expression]
        now = Time.now
        user = client.web_client.users_info(user: data.user).user
        user_id = user.id

        case parse_arg(arg)
        when "do_current_user"
          # if no argument
          user_name = user.profile.display_name
        when "do_specified_user"
          # if the user specified in the argument is active
          user_name = arg
        when "not_active_user"
          # if the user specified in the argument is not active
          msg = "ユーザ #{arg}は現役メンバではありません．"
          client.say(channel: data.channel, text: msg)
          next
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

      def self.parse_arg(arg)
        # judge if the user is specified in the argument
        active_members = spreadsheet.sheet("members", Swimmy::Resource::Member).fetch.select {|m| m.active? }.map {|m| m.account }

        case arg
        in nil
          # return "do_current_user" if arg is not specified
          return "do_current_user"
        in String => s if active_members.include?(s)
          # return "do_specified_user" if the user specified in the argument is active
          return "do_specified_user"
        else
          # return "not_active_user" if the user specified in the argument is not active
          return "not_active_user"
        end
      end # method parse_arg
    end # class Attendance
  end # module Command
end # module Swimmy

# coding: utf-8
#
# Restart swimmy system
#

module Swimmy
  module Command
    class Restart < Swimmy::Command::Base

      command "restart" do |client, data, match|
        puts client.class
        client.say(channel: data.channel, text: "再起動します")

        begin
          exe_file = Dir::pwd + "/exe/swimmy"
          exec("bundle exec #{exe_file} --hello 再起動完了!")
        rescue => e
          client.say(channel: data.channel, text: "再起動に失敗しました．")
          raise e
        end
      end

      help do
        title "restart"
        desc "swimmyを再起動します．"
        long_desc "swimmyを再起動します．引数はありません．"
      end

    end # class Restart
  end # module Command
end # module Swimmy
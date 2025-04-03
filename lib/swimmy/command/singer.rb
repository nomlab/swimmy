require 'rspotify'

module Swimmy
  module Command
    class Singer < Swimmy::Command::Base
      command "singer" do |client, data, match|   
        client.say(channel: data.channel, text: "This is singer command")
        # singer_name = match[:expression]
        # client.say(channel: data.channel, text: "input singer name: " + singer_name)

        singer_name = match[:expression]
        if singer_name.nil? then
          client.say(channel: data.channel, text: "引数の数が正しくありません．検索するアーティスト名を<artist>として以下のように入力してください．\n" +
            "singer <artist>\n")
        else
          client.say(channel: data.channel, text: "アーティスト名を取得中...")
        end

        client.say(channel: data.channel, text: "command expression: " + match[:expression].to_s)
        
        
          # shops = Swimmy::Service::Coop.new.get_shopinfolist("https://vsign.jp/okadai/maruco/shops")
        # script = ""
        # case match[:expression]
        # when "open"
        #   pred = ->(s){s.open?(Time.new)}
        # when "time"
        #   pred = ->(_){true}
        # end
        # script = shops.select(&pred).map{|s| s.to_s}.join("\n")
        # client.say(channel: data.channel, text: script)
      end
      
      help do
        title "singer"
        desc "引数のアーティストの人気曲を表示する"
        long_desc "coop open - 空いているショップを表示する\n" +
                  "coop time - ショップごとの営業時間を表示する"
      end #help
    end #class Coop    
  end #module Command
end #module Swimmy
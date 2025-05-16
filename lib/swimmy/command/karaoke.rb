module Swimmy
  module Command
    class Karaoke < Swimmy::Command::Base
      karaoke_service = Swimmy::Service::Karaoke.new("https://www.clubdam.com/ranking/")
      
      def self.say_ranking(client, data, song_ranking_hash, title)
        text = "DAM カラオケ#{title}ランキング\n"
        text += "引用元：https://www.clubdam.com/ranking/\n"
        song_ranking_hash.each{|i, song| text += "#{i}位: #{song}\n"}                                       		
        client.say(channel: data.channel, text: text)
      end # say_ranking

      command "karaoke" do |client, data, match|
        case match[:expression]
        when nil, ""
          title, api_arg = "", "daily"
        when "daily"
          title, api_arg = "デイリー", "daily"
        when "weekly"
          title, api_arg = "ウィークリー", "weekly"
        when "monthly"
          title, api_arg = "マンスリー", "monthly"
        else
          client.say(channel: data.channel, text: "引数を間違えています．daily, weekly, monthly のいずれかまたは引数なしを入力してください")
          return nil
        end
        ranking_list = karaoke_service.get_karaoke_info(api_arg)
        Karaoke.say_ranking(client, data, ranking_list, title)
      end # command do
      help do
        title "karaoke"
        desc "DAMのカラオケデイリーランキングを表示する"
        long_desc "karaoke daily - カラオケデイリーランキングを表示する\n" +
                  "karaoke weekly - カラオケウィークリーランキングを表示する\n" +
                  "karaoke monthly - カラオケマンスリーランキングを表示する"
      end # help do
    end # class Karaoke
  end # module Command
end # module Swimmy

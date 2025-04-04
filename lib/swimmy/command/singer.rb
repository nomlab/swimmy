require 'rspotify'

module Swimmy
  module Command
    class Singer < Swimmy::Command::Base
      command "singer" do |client, data, match|   

        puts(match.class)

        # 結果を日本語で取得するための設定
        ENV['ACCEPT_LANGUAGE'] = "ja"
        
        # SpotifyのAPIを使用するための認証
        # arg: client ID, secret ID
        RSpotify.authenticate("fa061fbd0dc74c2ea6235d94d572c389", "8bf78053165b4e618a92dd62f0fd5cc6")

        case match[:expression]
        when "help"
          client.say(channel: data.channel, text: help_message("singer"))
        when nil
          client.say(channel: data.channel, text: "引数の数が正しくありません．検索するアーティスト名を<artist>として以下のように入力してください．\n" +
              "singer <artist>\n")
        else
          client.say(channel: data.channel, text: "アーティスト情報を取得中...")
        
          singer_name = match[:expression].split[0]
          artists = RSpotify::Artist.search(singer_name)

          # 引数で検索した中で一番上のアーティストを取得
          cand_artist = artists.first

          if cand_artist.nil? then
            client.say(channel: data.channel, text: "アーティストが見つかりませんでした．")
          else
            script = "#{singer_name} の楽曲ジャンル\n"

            genres = cand_artist.genres # ジャンルの配列
            genres.each do |genre|
              script << "・#{genre}\n"
            end

            tracks = cand_artist.top_tracks(:JP) # 人気トラックの配列
    
            # popularityの値が大きい順にソート
            sorted_tracks = tracks.sort_by{|track| track.popularity}.reverse
    
            script << "#{singer_name} の人気曲\n"

            sorted_tracks.each do |track|
              script << "・#{track.name}\n"
            end

            script += "\"#{singer_name}\"の関連アーティスト\n"
            for i in 1..3 do
              script << "・#{artists[i].name}\n"
            end

            client.say(channel: data.channel, text: script)
          end
        end 
      end #command
      
      help do
        title "singer"
        desc "アーティストに関連する情報を表示する"
        long_desc "singer <artist name> - アーティストの楽曲ジャンル，人気楽曲，関連アーティストを表示します"
      end #help
    end #class Coop    
  end #module Command
end #module Swimmy
module Swimmy
  module Command
    class Artist < Swimmy::Command::Base
      command "artist" do |client, data, match|   
        case match[:expression]
        when nil
          msg = "引数の数が正しくありません．検索するアーティスト名を入力してください．"
        when "help"
          msg = help_message("artist")
        else        
          begin 
            spotify = Swimmy::Service::Spotify.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
            artist_info = spotify.search(match[:expression])
          rescue => e
            msg = "アーティスト情報を取得できませんでした．API認証に失敗した可能性があります．"
          end

          # 人気曲は最大10件，関連アーティストは最大5件
          num_tracks = 10
          num_related_artists = 5
          msg = make_artist_message(artist_info, num_tracks, num_related_artists)  
        end 
        
        client.say(channel: data.channel, text: msg)
      end #command

      def self.make_artist_message(artist_info, num_tracks, num_related_artists)
        msg = ""
        msg << "検索結果: *#{artist_info.name}*\n"
        
        msg << "*[楽曲ジャンル]*\n"
        artist_info.genres.each { |genre| msg << "・#{genre}\n" }
        
        msg << "*[人気曲]*\n"
        artist_info.popular_tracks(num_tracks).each { |track| msg << "・#{track}\n" }
        
        msg << "*[関連アーティスト]*\n"
        artist_info.related_artists(num_related_artists).each { |related_artist| msg << "・#{related_artist}\n" }
        
        return msg
      end
      
      help do
        title "artist"
        desc "アーティストに関連する情報を表示します"
        long_desc "artist <artist name> - アーティストの楽曲ジャンル，人気楽曲，関連アーティストを表示します"
      end #help
    end #class Coop    
  end #module Command
end #module Swimmy

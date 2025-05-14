module Swimmy
  module Command
    class Artist < Swimmy::Command::Base
      command "artist" do |client, data, match|   
        case match[:expression]
        when nil
          client.say(channel: data.channel, text: "引数の数が正しくありません．検索するアーティスト名を入力してください．")
        when "help"
          client.say(channel: data.channel, text: help_message("artist"))
        else        
          begin 
            # SpotifyのAPIを使用するための認証 
            spotify = Swimmy::Service::Spotify.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
            artist = spotify.search(match[:expression])

            
            artist_name = artist.name
            genres = artist.genres
            tracks = artist.popular_tracks
            related_artists = artist.related_artists
  
            client.say(channel: data.channel, text: "アーティスト情報を取得中...")

            message = ""
            message << "*#{match[:expression]}* の検索結果 ⇒ *#{artist_name}*\n"
  
            message << "*[楽曲ジャンル]*\n"
            genres.each { |genre| message << "・#{genre}\n"}
  
            message << "*[人気曲]*\n"
            tracks.each { |track| message << "・#{track}\n"}
  
            message << "*[関連アーティスト]*\n"
            related_artists.each { |related_artist| message << "・#{related_artist}\n"}
  
            client.say(channel: data.channel, text: message)
          rescue => e
            client.say(channel: data.channel, text: "アーティスト情報を取得できませんでした．API認証に失敗した可能性があります．")
          end
        end 
      end #command
      
      help do
        title "artist"
        desc "アーティストに関連する情報を表示します"
        long_desc "artist <artist name> - アーティストの楽曲ジャンル，人気楽曲，関連アーティストを表示します"
      end #help
    end #class Coop    
  end #module Command
end #module Swimmy
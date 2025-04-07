require 'rspotify'

module Swimmy
  module Service
    class Spotify

      def initialize(client_id, client_secret)
        ENV['ACCEPT_LANGUAGE'] = "ja"
        # SpotifyのAPIを使用するための認証
        RSpotify.authenticate(client_id, client_secret)
      end

      def search_artist_candidates(artist_name)
        # 引数で検索した中で一番上のアーティストを取得
        artists = RSpotify::Artist.search(artist_name)
        if artists.empty?  
          return nil
        else
          return artists
        end

      end
    end #class Spotify
  end #module Service
end #module Swimmy
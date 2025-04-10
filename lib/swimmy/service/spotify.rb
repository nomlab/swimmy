require 'rspotify'

module Swimmy
  module Service
    class Spotify

      def initialize(client_id, client_secret)
        # 結果を日本語で取得するための設定
        ENV['ACCEPT_LANGUAGE'] = "ja"
        # SpotifyのAPIを使用するための認証
        RSpotify.authenticate(client_id, client_secret)
      end

      def search(artist_name)
        artists = RSpotify::Artist.search(artist_name)
        if artists.empty?  
          return nil
        else
          return Swimmy::Resource::ArtistInfo.new(artists.first)
        end
      end

      def search_related_artists(artist_name, n)
        artists = RSpotify::Artist.search(artist_name)
        if artists.empty?  
          return nil
        else
          related_artists = []
          for i in 0..n-1
            # 検索結果中，2番目以降のアーティスト名を取り出す
            related_artists << artists[i + 1].name
          end

          return related_artists
        end
      end
    end #class Spotify
  end #module Service
end #module Swimmy
module Swimmy
  module Service
    class Spotify
      require 'rspotify'

      def initialize(client_id, client_secret)
        # 結果を日本語で取得するための設定
        ENV['ACCEPT_LANGUAGE'] = "ja"
        # Spotify-APIの認証
        RSpotify.authenticate(client_id, client_secret)
      end

      def search(artist_name)
        # 先頭要素のアーティストを検索結果とする
        artist = RSpotify::Artist.search(artist_name).first
        name = artist.name
        genres = artist.genres
        tracks = artist.top_tracks(:JP)
        related_artists = []
        for i in 0..2
          # 検索結果中，2番目以降のアーティストを3件取り出す
          related_artists << artists[i + 1]
        end

        return Swimmy::Resource::ArtistInfo.new(name, genres, tracks, related_artists)
      end
    end # class Spotify
  end # module Service
end # module Swimmy
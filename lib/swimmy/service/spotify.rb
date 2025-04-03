module Swimmy
  module Service
    class Spotify
      require 'rspotify'

      def initialize(client_id, client_secret)
        # Spotify-APIの認証
        RSpotify.authenticate(client_id, client_secret)
      end

      def search(artist_name)
        artists = RSpotify::Artist.search(artist_name)
        # 先頭要素のアーティストを検索結果とする
        artist = artists.first
        name = artist.name
        genres = artist.genres
        tracks = artist.top_tracks(:JP)

        return Swimmy::Resource::ArtistInfo.new(name, genres, tracks, artists)
      end
    end # class Spotify
  end # module Service
end # module Swimmy

module Swimmy
  module Service
    class Spotifyapi
      require 'rspotify'

      def initialize(client_id, client_secret)
        ENV['ACCEPT_LANGUAGE'] = "ja"
        RSpotify.authenticate(client_id, client_secret)
      end

      def search_artist_candidates(artist_name)
        # 引数で検索した中で一番上のアーティストを取得
        artists = RSpotify::Artist.search(artist_name)
        if artists.empty?  
          return nil
        else
          return artists.first
        end

      end
    end #class Spotifyapi
  end #module Service
end #module Swimmy
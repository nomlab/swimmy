module Swimmy
  module Resource
    class Artist
      def initialize(artist)
        @artist = artist
      end

      def get_name
        return @artist.name
      end

      def get_genres
        genrus = []
        @artist.genres.each do |genre|
          genrus << "#{genre}"
        end

        return genrus
      end

      def get_popular_tracks
        tracks = []
        @artist.top_tracks(:JP).each do |track|
          tracks << "#{track.name}"
        end

        return tracks
      end
      
    end
  end
end  # module Swimmy
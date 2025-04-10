module Swimmy
  module Resource
    class ArtistInfo
      def initialize(artist)
        @artist = artist
        @name = artist.name
      end

      def get_name
        return @name
      end

      def get_genres
        genrus = []
        @artist.genres.each do |genre|
          genrus << "#{genre}"
        end

        return genrus
      end

      def get_popular_tracks
        tracks = @artist.top_tracks(:JP)
        # popularityの値が大きい順にソート
        sorted_tracks = tracks.sort_by{|track| track.popularity}.reverse
        tracks = []
        sorted_tracks.each do |track|
          tracks << "#{track.name}"
        end
        return tracks
      end
      
    end
  end
end  # module Swimmy
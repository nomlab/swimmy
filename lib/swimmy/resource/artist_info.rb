module Swimmy
  module Resource
    class ArtistInfo
      def initialize(name, genres, tracks, related_artists)
        @name = name
        @genres = genres  
        @tracks = tracks
        @related_artists = related_artists
      end

      def get_name
        return @name
      end

      def get_genres
        genrus = []
        @genres.each do |genre|
          genrus << "#{genre}"
        end

        return genrus
      end

      def get_popular_tracks
        # popularityの値が大きい順にソート
        sorted_tracks = @tracks.sort_by{|track| track.popularity}.reverse
        tracks = []
        sorted_tracks.each do |track|
          tracks << "#{track.name}"
        end
        return tracks
      end

      def get_related_artists
        related_artists = []
        @related_artists.each do |related_artist|
          related_artists << "#{related_artist.name}"
        end
        return related_artists
      end      
    end
  end
end  # module Swimmy
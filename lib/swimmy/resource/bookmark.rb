module Swimmy
  module Resource
    class BookmarkEntry

      class InvalidTitleException < StandardError; end

      attr_accessor :user_name, :url, :title, :active
      attr_reader :id
  
      def initialize(user_name, url, title, active = true, id = nil)
        if title =~ /\A[1-9][0-9]*\z/
          raise InvalidTitleException.new
        end
        @user_name = user_name
        @url = url
        @title = title
        @active = (active == "true" || active == true)
        @id = id || SecureRandom.uuid
      end
      
      def to_a
        [
          @user_name,
          @url,
          @title,
          @active ? "true" : "false",
          @id
        ]
      end
  
      def disable
        return BookmarkEntry.new(@user_name, @url, @title, false)
      end # class BookmarkEntryWithUID
    end # class BookmarkEntry
  end # module Resource
end # module Swimmy

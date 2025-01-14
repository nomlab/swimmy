module Swimmy
  module Resource
    class BookmarkEntry

      class InvalidTitleException < StandardError; end

      attr_accessor :user_name, :url, :title, :active
      attr_reader :id
  
      def initialize(user_name, url, title, active = true)
        if title =~ /\A[1-9][0-9]*\z/
          raise InvalidTitleException.new
        end
        @user_name = user_name
        @url = url
        @title = title
        @active = (active == "true" || active == true)
        @id = SecureRandom.uuid
      end
      
      def to_a
        [
          @user_name,
          @url,
          @title,
          @active ? "true" : "false"
        ]
      end

      def add_id
        return BookmarkEntryWithUID.new(@id, @user_name, @url, @title, true)
      end

      class BookmarkEntryWithUID < BookmarkEntry
        def initialize(id, user_name, url, title, active = true)
          super(user_name, url, title, active)
          @id = id
        end
  
        def to_a
          [
            @id,
            @user_name,
            @url,
            @title,
            @active ? "true" : "false"
          ]
        end
  
        def disable
          return BookmarkEntryWithUID.new(@id, @user_name, @url, @title, false)
        end
      end # class BookmarkEntryWithUID
    end # class BookmarkEntry
  end # module Resource
end # module Swimmy

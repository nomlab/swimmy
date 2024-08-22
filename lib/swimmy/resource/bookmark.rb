module Swimmy
    module Resource
      class BookmarkEntry
  
        class InvalidTitleException < StandardError; end
  
        attr_accessor :user_name, :url, :title, :active
    
        def initialize(user_name, url, title, active = true)
          if title =~ /\A[1-9][0-9]*\z/
            raise InvalidTitleException.new
          end
          @user_name = user_name
          @url = url
          @title = title
          @active = (active == "true" || active == true)
        end
    
        def to_a
          [
            @user_name,
            @url,
            @title,
            @active? "true" : "false"
          ]
        end
  
        def disable
          return BookmarkEntry.new(@user_name, @url, @title, false)
        end
  
      end # class BookmarkEntry
    end # module Resource
  end # module Swimmy
  
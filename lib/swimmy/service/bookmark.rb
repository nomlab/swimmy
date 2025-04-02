module Swimmy
  module Service
    class Bookmark

      def initialize(spreadsheet)
        @sheet = spreadsheet.sheet("bookmark", Swimmy::Resource::BookmarkEntry)
        @row = @sheet.fetch
        @active = @row.select { |row| row.active == true }
      end

      def exist?(bookmark_entry)
        return @active.any?{|row| row.user_name == bookmark_entry.user_name && row.url == bookmark_entry.url}
      end

      def search_by_index(user, index)
        bookmark = @active.select{|row| row.user_name == user}
        return bookmark[index]
      end

      def search_by_url_or_title(user, word)
        return @active.find{|row| row.user_name == user && (row.url == word || row.title == word)}
      end

      def add(bookmark_entry)
        @sheet.append_row(bookmark_entry)
      end

      def delete(bookmark_entry)
        row_num = @row.index(bookmark_entry) + 2
        disable_entry = bookmark_entry.disable
        @sheet.update_row(disable_entry, row_num)
      end

      def find_bookmark_by_user_name(user)     
        list = @active.select{|row| row.user_name == user}
        return list
      end
    end
  end
end

module Swimmy
  module Service
    class Bookmark

      def initialize(spreadsheet)
        @sheet = spreadsheet.sheet("bookmark", Swimmy::Resource::BookmarkEntry::BookmarkEntryWithUID)
        @row = @sheet.fetch.select { |row| row.active == true }
      end

      def exist?(bookmark_entry)
        return @row.any?{|row| row.user_name == bookmark_entry.user_name && row.url == bookmark_entry.url}
      end

      def search_by_index(user, index)
        bookmark = @row.select{|row| row.user_name == user}
        return bookmark[index]
      end

      def search_by_url_or_title(user, word)
        return @row.find{|row| row.user_name == user && (row.url == word || row.title == word)}
      end

      def add(bookmark_entry)
        bookmark_entry = bookmark_entry.add_id
        @sheet.append_row(bookmark_entry)
      end

      def delete(bookmark_entry)
        disable_entry = bookmark_entry.disable
        @sheet.update_row_including_keyword(disable_entry.id, disable_entry)
      end

      def find_bookmark_by_user_name(user)     
        list = @row.select{|row| row.user_name == user}
        return list
      end
    end
  end
end

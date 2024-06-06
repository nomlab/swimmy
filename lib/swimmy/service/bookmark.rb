module Swimmy
  module Service
    class Bookmark

      def initialize(spreadsheet)
        @sheet = spreadsheet.sheet("bookmark", Swimmy::Resource::BookmarkEntry)
        @bookmark = @sheet.fetch
      end

      def exist?(bookmark_entry)
        return @bookmark.any?{|row| row.user_name == bookmark_entry.user_name && row.url == bookmark_entry.url && row.active}
      end

      def search_by_index(user, index)
        list = @bookmark.each_with_index.select{|row, row_num| row.user_name == user && row.active}
        map = list.map{|row, row_num| [row, row_num + 2]}
        return map[index]
      end

      def search_by_url_or_title(bookmark_entry)
        list = @bookmark.each_with_index.select{|row, row_num| row.user_name == bookmark_entry.user_name && (row.url == bookmark_entry.url || row.title == bookmark_entry.title) && row.active}
        map = list.map{|row, row_num| [row, row_num + 2]}
        return map.first
      end

      def add(bookmark_entry)
        @sheet.append_row(bookmark_entry)
      end

      def delete(bookmark_entry)
        entry = bookmark_entry[0]
        row_num = bookmark_entry[1]
        entry = entry.disable
        @sheet.update_row(entry, row_num)
      end

      def find_bookmark_by_user_name(user)
        list = @bookmark.select{|row| row.user_name == user && row.active}
        return list
      end

    end
  end
end

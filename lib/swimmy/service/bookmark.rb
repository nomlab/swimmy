module Swimmy
    module Service
      class Bookmark
  
        def initialize(spreadsheet)
          @sheet = spreadsheet.sheet("bookmark", Swimmy::Resource::BookmarkEntry)
          @row = @sheet.fetch
          @row_with_row_num = @row.each_with_index.map{|row, index| [row, index + 2]}
        end
  
        def exist?(bookmark_entry)
          return @row.any?{|row| row.user_name == bookmark_entry.user_name && row.url == bookmark_entry.url && row.active}
        end
  
        def search_by_index(user, index)
          bookmark = @row_with_row_num.select{|row| row[0].user_name == user && row[0].active}
          return bookmark[index]
        end
  
        def search_by_url_or_title(bookmark_entry)
          return @row_with_row_num.find{|row| row[0].user_name == bookmark_entry.user_name && (row[0].url == bookmark_entry.url || row[0].title == bookmark_entry.title) && row[0].active}
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
          list = @row.select{|row| row.user_name == user && row.active}
          return list
        end
      end
    end
  end
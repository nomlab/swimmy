module Swimmy
    module Command
      class Bookmark < Swimmy::Command::Base
  
        command "bookmark" do |client, data, match|
          if match[:expression]
            arg = match[:expression].split(" ")
            if arg.length < 2
              msg = "コマンドが正しくありません．helpで確認してください．\n"
              client.say(channel: data.channel, text: msg)
              next
            end
            sub_command = arg[0]
            url = arg[1]
            title = arg[2..-1].join(" ")
            target = arg[1..-1].join(" ")
          end
          usr = client.web_client.users_info(user: data.user).user.profile.display_name
          bookmark = Swimmy::Service::Bookmark.new(spreadsheet)
          case sub_command
          when "add"
            begin
              entry = Swimmy::Resource::BookmarkEntry.new(usr, url, title)
            rescue Swimmy::Resource::BookmarkEntry::InvalidTitleException
              msg = "数字のみのタイトルをつけることはできません．\n" 
              client.say(channel: data.channel, text: msg)
              next
            end
            unless bookmark.exist?(entry)
              bookmark.add(entry)
              msg = "URLをブックマークに登録しました．\n"
            else
              msg = "対象のURLは既にブックマークに登録されています．\n"
            end
          when "delete"
            if target =~ /\A[1-9][0-9]*\z/
              num = target.to_i - 1
              entry = bookmark.search_by_index(usr, num)
            else
              entry = bookmark.search_by_url_or_title(usr, target)
            end
            if entry == nil
              msg = "削除対象が存在しません．\n"
            else
              bookmark.delete(entry)
              msg = "URLをブックマークから削除しました．\n"
            end
          when nil
            user_bookmark = bookmark.find_bookmark_by_user_name(usr)
            msg = "#{usr}さんのブックマークを表示します．\n"
            if user_bookmark == []
              msg << "ブックマークが存在しません．\n"
            end
            user_bookmark.each_with_index do |row, index|
              if row.title == ""
                msg << "#{index + 1}．#{row.url}\n"
              else
                msg << "#{index + 1}．#{row.title}: #{row.url}\n"
              end
            end
          else
            msg = "コマンドが正しくありません．helpで確認してください．\n"
          end
          client.say(channel: data.channel, text: msg)
        end
  
        help do
          title "bookmark"
          desc "指定したURLをブックマークに登録します"
          long_desc "bookmark\n" +
                    "現在登録されているブックマークを全件表示します．\n" +
                    "bookmark add URL [TITLE]\n" +
                    "URLをブックマークに登録します．\n" +
                    "bookmark delete URL|TITLE|INDEX\n" +
                    "指定したURL|TITLE|INDEXにmacthするブックマークを削除します．INDEXは全件表示から確認できます．\n"
        end
      end # class Bookmark
    end # module command
  end # module swimmy
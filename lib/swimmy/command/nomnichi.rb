# coding: utf-8
module Swimmy
  module Command
    class Nomnichi < Swimmy::Command::Base

      command "nomnichi" do |client, data, match|
        client.say(channel: data.channel, text: "履歴取得中...")

        begin
          assignees = WorkHorse.new(spreadsheet).whosnext(3)
        rescue Exception => e
          client.say(channel: data.channel, text: "履歴を取得できませんでした.")
          raise e
        end

        client.say(channel: data.channel, text: "次回のノムニチ担当は，#{assignees.join(', ')} さんです!")
      end

      help do
        title "nomnichi"
        desc "次のノムニチ執筆者を教えてくれます"
        long_desc "次のノムニチ執筆者を教えてくれます．引数はありません．"
      end

      ################################################################
      ## private inner class

      class WorkHorse
        require "sheetq"
        attr_reader :spreadsheet

        def initialize(spreadsheet)
          @spreadsheet = spreadsheet
        end

        def whosnext(max_candidates = 1)
          whos_next(nomnichi_active_members, fetch_nomnichi_articles, max_candidates)
        end

        private

        def nomnichi_active_members
          spreadsheet.sheet("members", Swimmy::Resource::Member).fetch.select {|m| m.active? }.map(&:account)
        end

        def fetch_nomnichi_articles
          Sheetq::Service::Nomnichi.new.fetch
        end

        def whos_next(current_member_account_names, articles, max_candidates = 1)
          epoch = Time.new(1970, 1, 1)
          old_to_new_articles =  articles.sort {|a, b| a.published_on <=> b.published_on}
          latest_published_time = Hash.new

          current_member_account_names.each do |user_name|
            latest_published_time[user_name] = epoch
          end

          old_to_new_articles.each do |article|
            next unless current_member_account_names.include?(article.user_name)
            latest_published_time[article.user_name] = article.published_on
          end

          return latest_published_time.sort{|a, b| a[1] <=> b[1]}.take(max_candidates).map(&:first)
        end
      end
      private_constant :WorkHorse

    end # class Nomnichi
  end # module Command
end # module Swimmy

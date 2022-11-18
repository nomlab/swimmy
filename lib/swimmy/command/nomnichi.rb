# coding: utf-8
module Swimmy
  module Command
    class Nomnichi < Swimmy::Command::Base

      command "nomnichi" do |client, data, match|
        client.say(channel: data.channel, text: "履歴取得中...")

        begin
          targets = WorkHorse.new(spreadsheet).nomnichi_targets
        rescue Exception => e
          client.say(channel: data.channel, text: "履歴を取得できませんでした.")
          raise e
        end

        case match[:expression]
        when nil
          client.say(channel: data.channel, text: "次回のノムニチ担当は，#{targets.first} さんです!")
        when 'list'
          client.say(channel: data.channel, text: "次回以降のノムニチ担当は，以下の通りです!\n#{targets.join("\n")}")
        else
          client.say(channel: data.channel, text: help_message("nomnichi"))
        end
      end

      help do
        title "nomnichi"
        desc "次のノムニチ執筆者を教えてくれます"
        long_desc "nomnichi list - 次回以降のノムニチ執筆者を教えてくれます．"
      end

      ################################################################
      ## private inner class

      class WorkHorse
        require "sheetq"
        attr_reader :spreadsheet

        def initialize(spreadsheet)
          @spreadsheet = spreadsheet
        end

        def nomnichi_targets
          capture_targets(nomnichi_active_members, fetch_nomnichi_articles)
        end

        private

        def nomnichi_active_members
          spreadsheet.sheet("members", Swimmy::Resource::Member).fetch.select {|m| m.active? }.map(&:account)
        end

        def fetch_nomnichi_articles
          Sheetq::Service::Nomnichi.new.fetch
        end

        def capture_targets(current_member_account_names, articles)
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

          return latest_published_time.sort{|a, b| a[1] <=> b[1]}.map(&:first)
        end
      end
      private_constant :WorkHorse

    end # class Nomnichi
  end # module Command
end # module Swimmy

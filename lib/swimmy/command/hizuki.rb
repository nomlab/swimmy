# coding: utf-8
module Swimmy
  module Command
    class Hizuki < Swimmy::Command::Base
      require 'date'
      require 'json'
      require 'uri'
      require 'net/http'
      
      command "hizuki" do |client, data, match|

        date_expr = /\A(\d+)\/(\d+)\Z/
        year_expr = /\A([\+-]?\d+)\Z/
        case match[:expression]
        when date_expr
          message = self.get_date_event_message($1.to_i, $2.to_i)
        when year_expr
          message = self.get_year_event_message($1.to_i)
        when "help"
          message = help_message("hizuki")
        else
          message = "run \"hizuki help\""
        end

        client.say(channel: data.channel, text: message)
      end

      help do
        title "hizuki"
        desc "  西暦や日付に関係する雑学を教えてくれます．"
        long_desc "hizuki MM/DD - MM月DD日に関係する雑学を教えてくれます．\n" +
                  "hizuki YYYY - 西暦YYYYに関係する雑学を教えてくれます．\n"  
      end

      def self.get_date_event_message(month=0, day=0)
        return "#{month}/#{day} は存在しない日付です" if !Date.valid_date?(4, month, day)

        numbersapi = Swimmy::Service::Numbersapi.new
        en_text = numbersapi.fetch_date_event(month, day)
        return "#{month}/#{day}に関する情報はありませんでした" if en_text.nil?

        self.gen_message(en_text)
      end

      def self.get_year_event_message(year=0)
        return "#{year}年は未来の年です" if year > Date.today.year
        return "西暦0年は存在しません" if year==0

        numbersapi = Swimmy::Service::Numbersapi.new
        en_text = numbersapi.fetch_year_event(year)
        if en_text.nil? then
          era = if year < 0 then "紀元前#{-year}年" else "#{year}年" end
          return "#{era}に関する情報はありませんでした" 
        end
        
        self.gen_message(en_text)
      end

      def self.gen_message(en_text)
        ja_text = Swimmy::Service::Translate.new("en", "ja").translate(en_text)
        ja_text = if ja_text.nil? then "翻訳できませんでした" else ja_text end

        text = <<~EOS 
        [trivia]
        #{en_text}
        

        #{ja_text}
        EOS
      end
    end # class Plan
  end # module Command
end # module Swimmy

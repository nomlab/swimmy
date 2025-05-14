# coding: utf-8
module Swimmy
  module Command
    class Hizuki < Swimmy::Command::Base

      command "hizuki" do |client, data, match|
        hizuki = WorkHorse.new
        case match[:expression]
        when /\A(\d+)\/(\d+)\Z/
          message = hizuki.date($1.to_i, $2.to_i)
          client.say(channel: data.channel, text: message)
        when /\A([\+-]?\d+)\Z/
          message = hizuki.year($1.to_i)
          client.say(channel: data.channel, text: message)
        when "help"
          client.say(channel: data.channel, text: help_message("hizuki"))
        else
          client.say(channel: data.channel, text: "run \"hizuki help\"")
        end
      end

      help do
        title "hizuki"
        desc "  西暦や日付に関係する雑学を教えてくれます．"
        long_desc "hizuki MM/DD - MM月DD日に関係する雑学を教えてくれます．\n" +
                  "hizuki YYYY - 西暦YYYYに関係する雑学を教えてくれます．\n"  
      end

      ####################################################################
      ### private inner class
      class WorkHorse
        require 'date'
        require 'json'
        require 'uri'
        require 'net/http'

        def date(month=0, day=0)
          return "#{month}/#{day} は存在しない日付です" if !Date.valid_date?(4, month, day)

          uri_str = "http://numbersapi.com/#{month}/#{day}/date?json&default=There+is+no+infomation+about+the+day+#{month}/#{day}"
          uri_to_message(uri_str)
        end

        def year(year=nil)
          return "#{year}年は未来の年です" if year > Date.today.year
          return "西暦0年は存在しません" if year==0

          era = if year < 0 then "#{-year} BC" else "#{year}" end
          uri_str = "http://numbersapi.com/#{year}/year?json&default=There+is+no+infomation+about+the+year+#{era}"
          uri_to_message(uri_str)
        end

        def uri_to_message(uri_str)
          json = fetch_with_redirect(uri_str)
          parsed_json = JSON.parse(json)
          en_text = parsed_json["text"]
          ja_text = translate(en_text)

          return ja_text if parsed_json["found"]==false
          message(en_text, ja_text)
        end

        def fetch_with_redirect(uri_str, limit = 5)
          raise 'Too many HTTP redirects' if limit == 0
        
          parsed_uri = URI.parse(uri_str)
          response = Net::HTTP.get_response(parsed_uri)
        
          case response
          when Net::HTTPSuccess
            return response.body
          when Net::HTTPRedirection
            location = response['location']
            warn "redirected to #{location}"
            fetch_with_redirect(location, limit - 1)
          else
            nil
          end
        end

        def translate(en_text)
          translate_uri = "#{ENV['TRANSLATE_API_URL']}"
          translate_uri << "?text=#{en_text}&source=en&target=ja"
          translate_json = fetch_with_redirect(translate_uri)
          translate_content = JSON.parse(translate_json)
          text = if translate_content["code"]==200 then translate_content["text"] else "翻訳できませんでした" end
        end

        def message(en_text, ja_text)
          text = <<~EOS 
          [trivia]
          #{en_text}

          
          #{ja_text}
          EOS
        end

      end # class WorkHorse
      private_constant :WorkHorse

    end # class Plan
  end # module Command
end # module Swimmy

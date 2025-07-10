module Swimmy
  module Service
    class Translate
      require 'json'
      require 'uri'
      require 'net/http'

      #===language_select====
      # Japanese : "ja"
      # English  : "en"
      #======================
      
      def initialize(source_lang, target_lang)
        @source_lang = source_lang
        @target_lang = target_lang
      end

      def translate(text)
        translate_uri = "#{ENV['TRANSLATE_API_URL']}"
        translate_uri << "?text=#{text}&source=#{@source_lang}&target=#{@target_lang}"
        translate_json = fetch_with_redirect(translate_uri)
        translate_content = JSON.parse(translate_json)

        if translate_content["code"]==200 then translate_content["text"] else nil end
      end

      private

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
    end
  end
end

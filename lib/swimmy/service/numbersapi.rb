module Swimmy
  module Service
    class Numbersapi
      require 'json'
      require 'uri'
      require 'net/http'
      
      def initialize
        @base_url = "http://numbersapi.com"
      end

      def fetch_date_event(month=0, day=0)
        url = @base_url << "/#{month}/#{day}/date?json"
        fetch(url)
      end

      def fetch_year_event(year=0)
        url = @base_url << "/#{year}/year?json"
        fetch(url)
      end

      private

      def fetch(url)
        parsed_uri = URI.parse(url)
        json = Net::HTTP.get_response(parsed_uri).body
        parsed_json = JSON.parse(json)
        if parsed_json["found"]==true then parsed_json["text"] else nil end
      end
    end
  end
end

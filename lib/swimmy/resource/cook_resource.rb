module Swimmy
  module Resource
    class CookResource
      def initialize(name, description, url)
        @name, @description, @url = name, description, url
      end

      def make_message
        message = <<~EOS
        #{@name}
        #{@description}
        #{@url}
        EOS
      end
      
    end
  end
end

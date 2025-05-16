module Swimmy
  module Resource
    class UserLocation
      attr_accessor :user_name, :location_list, :prefix

      def initialize(user_name, prefix)
        @user_name = user_name
        @location_list = select_location_list
        @prefix = prefix
      end

      def select_location_list
        case @user_name
        when "nom"
          # 206号室の所在リスト
          {
            "hi"         => "在室",
            "meeting"    => "オンライン講義・会議中",
            "laboratory" => "研究室(105・106)",
            "lecture"    => "講義室",
            "department" => "学科内",
            "campus"     => "大学内",
            "bye"        => "帰宅・出張"
          }
        else
          # 106号室の所在リスト
          {
            "hi"      => "在室",
            "lecture" => "講義",
            "meeting" => "打合",
            "campus"  => "学内",
            "outside" => "学外", 
            "bye"     => "帰宅"
          }
        end
      end

      def retrieve_complement_location_list
        @location_list.select { |key, _| key.start_with?(@prefix) }
      end

      def get_min_prefix_list
        result = {}

        @location_list.keys.each do |key|
          min_prefix = key
          others = @location_list.keys.reject { |k| k == key }

          (1..key.length).each do |prefix_len|
            prefix = key[0, prefix_len]
            conflict = others.any? { |k| k.start_with?(prefix) }
            unless conflict
              min_prefix = prefix
              break
            end
          end
          result[key] = min_prefix
        end
        return result
      end

      def message_location_help
        prefix_list = get_min_prefix_list

        message = "引数を以下から1つを指定してください．\n\n" +
                  "引数(最小入力) :  所在名\n"
  
        @location_list.each do |key, value|
          message << "#{key} (#{prefix_list[key]}) :  #{value}\n"
        end
        return message
      end
    end #  class UserLocation
  end # module Resource
end # module Swimmy

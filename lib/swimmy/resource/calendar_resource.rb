require 'date'
require 'active_support/time'

module Swimmy
  module Resource
    class Schedule
      DateTimeInfo = Struct.new(:year, :month, :day, :hour, :min)
      ERROR_MESSAGES = {
        base: <<~TEXT,
          "swimmy calendar <カレンダー名> <予定名> <開始時刻> <終了時刻>" のように入力してください
          予定名に空白は使用できません
          また，時間のみ・日/時間・月/日/時間の入力の際は省略要素が自動で補完されます
          以下は入力例です
          "swimmy calendar nomlab 第48回開発打ち合わせ 4/18/10:00 4/18/12:00"
        TEXT
        invalid_args: "引数の長さが違います",
        invalid_date_format: "開始時刻と終了時刻の形式が統一されていないか，日付の形式が不正です",
        invalid_time_format: "時間の入力形式が不正です",
        not_exist_date: "不正な時刻形式，または存在しない日付です\n開始または終了時刻に誤りがあるか，無効な時刻が含まれています",
        invalid_time_order: "開始時刻が終了時刻よりも後，または等しくなっています\n開始時刻は終了時刻よりも前でなければなりません"
      }

      def initialize
        @current_time = Time.new
      end

      def build_event_info(arg)
        current_time = @current_time

        # check argument length
        return error_response(:invalid_args) unless valid_argument_length?(arg)

        calendar_name = arg[0]
        event_name = arg[1]
        start_date_parts = arg[2].split("/")
        end_date_parts = arg[3].split("/")

        # check date format
        return error_response(:invalid_date_format) unless valid_date_format?(start_date_parts, end_date_parts)

        date_length = start_date_parts.length
        start_time_parts = start_date_parts[date_length - 1].split(":")
        end_time_parts = end_date_parts[date_length - 1].split(":")

        # check time format
        return error_response(:invalid_time_format) unless valid_time_format?(start_time_parts, end_time_parts)

        # check and parse date/time
        begin
          start_info = parse_date(start_date_parts, start_time_parts, date_length)
          end_info = parse_date(end_date_parts, end_time_parts, date_length)
          raise ArgumentError unless valid_date?(start_info.year, start_info.month, start_info.day) || valid_date?(end_info.year, end_info.month, end_info.day)
          start_time = find_nearest_future_date(
            start_info.year, start_info.month, start_info.day,
            start_info.hour, start_info.min, current_time
          )
          end_time = find_nearest_future_date(
            end_info.year, end_info.month, end_info.day,
            end_info.hour, end_info.min, start_time
          )
        rescue => e
          return error_response(:not_exist_date)
        end

        # check start time before end time
        return error_response(:invalid_time_order) unless valid_time_order?(start_time, end_time)

        event_info = {
          calendar_name: calendar_name,
          event_name: event_name,
          start_time: start_time,
          end_time: end_time
        }
        return [true, event_info, nil]
      end

      private

      def error_response(key)
        return [false, nil, "#{ERROR_MESSAGES[key]}\n#{ERROR_MESSAGES[:base]}"]
      end

      def valid_argument_length?(arg)
        return arg.length == 4
      end

      def valid_date_format?(s_date, e_date)
        return s_date.length == e_date.length || s_date.length > 4 || e_date.length > 4
      end

      def valid_time_format?(s_time, e_time)
        return s_time.length == 2 && e_time.length == 2
      end

      def valid_time_order?(s_time, e_time)
        return s_time < e_time
      end

      def parse_date(date_parts, time_parts, date_length)
        case date_length
        # YYYY/MM/DD/hh:mm
        when 4
          year, month, day = date_parts[0..2].map(&:to_i)
        # MM/DD/hh:mm
        when 3
          year, month, day = [nil] + date_parts[0..1].map(&:to_i)
        # DD/hh:mm
        when 2
          year, month, day = [nil, nil] + [date_parts[0].to_i]
        # hh:mm
        when 1
          year, month, day = [nil, nil, nil]
        end
        hour, min = time_parts[0..1].map(&:to_i)
        return DateTimeInfo.new(year, month, day, hour, min)
      end

      def leap_year?(year)
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
      end

      def valid_date?(year, month, day)
        mday = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        case date_type(year, month, day)
        # YYYY/MM/DD/hh:mm
        when :full_date
          return false if year < 1 || month < 1 || month > 12 || day < 1
          if month == 2 && leap_year?(year)
            mday[2] = 29
          end
          return day <= mday[month]
        # MM/DD/hh:mm
        when :month_day_time
          return false if month < 1 || month > 12
          mday[2] = 29
          return day >= 1 && day <= mday[month]
        # DD/hh:mm
        when :day_time
          return day >= 1 && day <= 31
        # hh:mm
        when :time_only
          return true
        # invalid
        else
          return false
        end
      end

      def find_nearest_future_date(year, month, day, hour, min, base_time)
        base_year = base_time.year
        base_month = base_time.month
        base_day = base_time.day
        candidate_time = nil

        case date_type(year, month, day)
        # YYYY/MM/DD/hh:mm
        when :full_date
          candidate_time = Time.new(year, month, day, hour, min, 0)
        # MM/DD/hh:mm
        when :month_day_time
          candidate_time = Time.new(base_year, month, day, hour, min, 0)
          if candidate_time < base_time
            search_year = base_year
            search_year += 1
            while !valid_date?(search_year, month, day)
              search_year += 1
            end
            candidate_time = Time.new(search_year, month, day, hour, min, 0)
          end
        # DD/hh:mm
        when :day_time
          candidate_time = Time.new(base_year, base_month, day, hour, min, 0)
          if candidate_time < base_time || !valid_date?(base_year, base_month, day)
            search_year = base_year
            search_month = base_month
            while 1
              search_month += 1
              if search_month > 12
                search_year += 1
                search_month = 1
              end
              if valid_date?(search_year, search_month, day)
                candidate_time = Time.new(search_year, search_month, day, hour, min, 0)
                break
              end
            end
          end
        # hh:mm
        when :time_only
          candidate_time = Time.new(base_year, base_month, base_day, hour, min, 0)
          if candidate_time < base_time
            candidate_time += 1.day
          end
        # invalid
        else
          candidate_time = nil
        end

        return candidate_time
      end

      def date_type(year, month, day)
        case [year, month, day].count(nil)
        when 3 then :time_only
        when 2 then :day_time
        when 1 then :month_day_time
        when 0 then :full_date
        else nil
        end
      end

    end # class Schedule
  end # module Resource
end # module Swimmy

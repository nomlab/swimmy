require 'date'
require 'active_support/time'

module Swimmy
  module Resource
    class Schedule

      def leap_year?(year)
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
      end

      def valid_date?(year, month, day)
        nilCount = [year, month, day].count(nil)
        mday = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30]
        # DD
        if nilCount == 2
          return false if day < 1 || day > 31
          return true
        # MM/DD
        elsif nilCount == 1
          return false if month < 1 || month > 12
          mday[2] = 29
          return false if day < 1 || day > mday[month]
          return true
        # YYYY/MM/DD
        elsif nilCount == 0
          return false if year < 1 || month < 1 || month > 12 || day < 1
          if month == 2 && leap_year?(year)
            mday[2] = 29
          end
          return false if day > mday[month]
          return true
        # invalid
        else
          return false
        end
      end

      def find_nearest_future_date(year, month, day, hour, min, currentTime)
        currentYear = currentTime.year
        currentMonth = currentTime.month
        currentDay = currentTime.day

        case
        # hh:mm
        when year.nil? && month.nil? && day.nil?
          candidateTime = Time.new(currentYear, currentMonth, currentDay, hour, min, 0)
          if candidateTime < currentTime
            candidateTime += 1.day
          end

        # DD/hh:mm
        when year.nil? && month.nil? && !day.nil?
          candidateTime = Time.new(currentYear, currentMonth, day, hour, min, 0)
          if candidateTime < currentTime || !valid_date?(currentYear, currentMonth, day)
            searchYear = currentYear
            searchMonth = currentMonth
            while 1
              searchMonth += 1
              if searchMonth > 12
                searchYear += 1
                searchMonth = 1
              end
              if valid_date?(searchYear, searchMonth, day)
                candidateTime = Time.new(searchYear, searchMonth, day, hour, min, 0)
                break
              end
            end
          end

        # MM/DD/hh:mm
        when year.nil? && !month.nil? && !day.nil?
          candidateTime = Time.new(currentYear, month, day, hour, min, 0)
          if candidateTime < currentTime
            searchYear = currentYear
            searchYear += 1
            while !valid_date?(searchYear, month, day)
              searchYear += 1
            end
            candidateTime = Time.new(searchYear, month, day, hour, min, 0)
          end
        end

        return candidateTime
      end

      def valid_argument_length?(arg)
        return arg.length == 4
      end

      def valid_date_format?(sDate, fDate)
        return sDate.length == fDate.length || sDate.length > 4 || fDate.length > 4
      end

      def valid_time_format?(sTime, fTime)
        return sTime.length == 2 && fTime.length == 2
      end

      def valid_time_order?(sTime, fTime)
        return sTime < fTime
      end

      def parse_calendar_args(arg)
        currentTime = Time.now
        error = <<~TEXT
          "swimmy calendar <カレンダー名> <予定名> <開始時刻> <終了時刻>" のように入力してください
          予定名に空白は使用できません
          また，時間のみ・日/時間・月/日/時間の入力の際は省略要素が自動で補完されます
          以下は入力例です
          "swimmy calendar nomlab 第48回開発打ち合わせ 4/18/10:00 4/18/12:00"
        TEXT

        # check argument length
        msg = <<~TEXT
          引数の長さが違います
          #{error}
        TEXT
        return [false, nil, msg] unless valid_argument_length?(arg)

        calendarName = arg[0]
        eventName = arg[1]
        startSplitDate = arg[2].split("/")
        finishSplitDate = arg[3].split("/")

        # check date format
        msg = <<~TEXT
          開始時刻と終了時刻の形式が統一されていないか，日付の形式が不正です
          #{error}
        TEXT
        return [false, nil, msg] unless valid_date_format?(startSplitDate, finishSplitDate)
        dateLength = startSplitDate.length
        startSplitTime = startSplitDate[dateLength - 1].split(":")
        finishSplitTime = finishSplitDate[dateLength - 1].split(":")

        # check time format
        msg = <<~TEXT
          時間の入力形式が不正です
          #{error}
        TEXT
        return [false, nil, msg] unless valid_time_format?(startSplitTime, finishSplitTime)

        # check and parse date/time
        begin
          case dateLength
          when 4
            # YYYY/MM/DD/hh:mm
            raise ArgumentError unless valid_date?(startSplitDate[0].to_i, startSplitDate[1].to_i, startSplitDate[2].to_i)
            startTime = Time.new(startSplitDate[0].to_i, startSplitDate[1].to_i, startSplitDate[2].to_i, startSplitTime[0], startSplitTime[1], 0)
            finishTime = Time.new(finishSplitDate[0].to_i, finishSplitDate[1].to_i, finishSplitDate[2].to_i, finishSplitTime[0], finishSplitTime[1], 0)
          when 3
            # MM/DD/hh:mm
            raise ArgumentError unless valid_date?(nil, startSplitDate[0].to_i, startSplitDate[1].to_i)
            startTime = find_nearest_future_date(nil, startSplitDate[0].to_i, startSplitDate[1].to_i, startSplitTime[0].to_i, startSplitTime[1].to_i, currentTime)
            finishTime = find_nearest_future_date(nil, finishSplitDate[0].to_i, finishSplitDate[1].to_i, finishSplitTime[0].to_i, finishSplitTime[1].to_i, startTime)
          when 2
            # DD/hh:mm
            raise ArgumentError unless valid_date?(nil, nil, startSplitDate[0].to_i)
            startTime = find_nearest_future_date(nil, nil, startSplitDate[0].to_i, startSplitTime[0].to_i, startSplitTime[1].to_i, currentTime)
            finishTime = find_nearest_future_date(nil, nil, finishSplitDate[0].to_i, finishSplitTime[0].to_i, finishSplitTime[1].to_i, startTime)
          when 1
            # hh:mm
            startTime = find_nearest_future_date(nil, nil, nil, startSplitTime[0].to_i, startSplitTime[1].to_i, currentTime)
            finishTime = find_nearest_future_date(nil, nil, nil, finishSplitTime[0].to_i, finishSplitTime[1].to_i, startTime)
          end
        rescue => e
          msg = <<~TEXT
            不正な時刻形式，または存在しない日付です
            開始または終了時刻に誤りがあるか，無効な時刻が含まれています
          TEXT
          return [false, nil, msg]
        end

        # check start time before finish time
        msg = <<~TEXT
          開始時刻が終了時刻よりも後，または等しくなっています
          開始時刻は終了時刻よりも前でなければなりません
        TEXT
        return [false, nil, msg] unless valid_time_order?(startTime, finishTime)

        eventInfo = {
          calendarName: calendarName,
          eventName: eventName,
          startTime: startTime,
          finishTime: finishTime
        }
        return [true, eventInfo, nil]
      end
    end # class Schedule
  end # module Resource
end # module Swimmy
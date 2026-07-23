module Swimmy
  module Service
    class Doorplate
      def initialize(mqtt_client)
        @mqtt = mqtt_client
      end

      def send_attendance_event(attendance, user_name)
        require "json"

        topic = "cmd/pinot/v1/ou/eng4/doormgr/state"
        payload = JSON.dump({
          # Slack の user_name と door-mgr の member は対応している．
          # しかし door-mgr では`-`が利用できず`_`に置換したものを期待しているため変換する．
          # e.g. user_name: "fujiwara-e" -> member: "fujiwara_e"
          member: user_name.tr('-','_'),
          position: attendance,
        })

        @mqtt.publish(topic, payload)
      end
    end
  end
end

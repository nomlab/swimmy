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
          member: user_name.tr('-','_'),
          position: attendance,
        })

        @mqtt.publish(topic, payload)
      end
    end
  end
end

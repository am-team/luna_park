# frozen_string_literal: true

module LunaPark
  class Entity
    def initialize(attrs = {})
      self.attributes = attrs
    end

    def attributes=(attrs)
      attrs.each do |k,v|
        send "#{k}=", v
      end
    end

    class << self
      def wrap(attrs)
        case attrs
        when self.class then attrs
        when Hash then new(attrs)
        else raise ArgumentError, "Can`t wrap #{attrs.class}"
        end
      end
    end
  end
end
module Mixpal
  module Util
    class << self
      def hash_to_js_object_string(hash)
        hash.reject! { |_, v| v.nil? }

        contents = hash.map do |k, v|
          "\"#{k}\": #{escape_js_object_value(v)}"
        end.join(',').html_safe

        "{#{contents}}"
      end

      def escape_js_object_value(value)
        case value
        when String
          value.dump
        when Time
          "\"#{value}\""
        else
          value
        end
      end
    end
  end
end

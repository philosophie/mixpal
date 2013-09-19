module Mixpal
  module Util
    class << self
      def hash_to_js_object_string(hash)
        contents = hash.map do |k,v|
          js_value = v.is_a?(String) || v.is_a?(Time) ? "\"#{v}\"" : v
          "\"#{k}\": #{js_value}"
        end.join(",").html_safe

        "{#{contents}}"
      end
    end
  end
end
class Mustache
  module Utils
    class String
      def initialize string
        @string = string
      end

      def underscore(view_namespace)
        @string
          .dup
          .split("#{view_namespace}::")
          .last
          .split('::')
          .map do |part|
            part[0] = part[0].downcase
            part.gsub(/[A-Z]/) { |s| '_'.dup << s.downcase }
          end
          .join('/')
      end
    end
  end
end

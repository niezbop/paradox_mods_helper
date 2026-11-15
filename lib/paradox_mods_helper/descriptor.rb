require 'ostruct'

module ParadoxModsHelper
  class Descriptor < OpenStruct
    class Reader
      def read(path)
        raise ArgumentError, "#{path} is not a file" unless File.file?(path)

        attributes = {}

        lines = File.readlines(path)

        i = 0
        while i < lines.count do
          line = lines[i]
          k,v = line.strip.split('=', 2)
          if v.start_with?('{')
            v = []
            loop do
              i += 1
              break if lines[i].include?('}')
              v << sanitize_value(lines[i].strip)
            end
          else
            v = sanitize_value(v)
          end

          attributes[k] = v
          i += 1
        end

        return Descriptor.new(attributes)
      end

      def sanitize_value(value)
        return value.delete_prefix('"').delete_suffix('"').strip
      end
    end

    class << self
      def from_file(path)
        return Reader.new.read(path)
      end

      def glob(root)
        Dir.chdir(root) do
          return Dir.glob('**/descriptor.mod').map { |path| self.from_file(File.expand_path(path)) }
        end
      end
    end
  end
end

# frozen_string_literal: true

module ParadoxModsHelper
  module Target
    MARKER = '.paradox-mods-target'

    def self.find(start_dir)
      dir = File.expand_path(start_dir)

      until dir == '/'
        candidate = File.join(dir, MARKER)

        if File.file?(candidate)
          content = File.read(candidate).strip
          return File.expand_path(content) unless content.empty?
        end

        dir = File.dirname(dir)
      end

      return nil
    end
  end
end

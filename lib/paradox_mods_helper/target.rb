# frozen_string_literal: true

module ParadoxModsHelper
  module Target
    MARKER = '.paradox-mods-target'

    def self.resolve(path = nil)
      return File.expand_path(path) unless path.nil?

      target = find(Dir.pwd)

      if target.nil?
        say "no valid .paradox-mods-target found in #{Dir.pwd} or its parents — create one at your modding root containing the target mod directory path, or pass --target PATH"
        exit(1)
      end

      return target
    end

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

# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module ParadoxModsHelper
  class Registry
    attr_reader :entries

    DIRECTORY_PATH = File.expand_path(File.join('~', '.paradox_mods_helper')).freeze
    FILE_PATH = File.join(DIRECTORY_PATH, 'local_mods.yml').freeze
    SERIALIZATION_KEY = :local_mods.freeze

    def initialize(entries = {})
      @entries = entries
    end

    def add(identifier, path, overwrite: false)
      existing = @entries[identifier]
      return :unchanged if existing == path
      return :conflict if existing && !overwrite

      @entries[identifier] = path
      return existing ? :replaced : :added
    end

    def self.exists?
      File.file?(FILE_PATH)
    end

    def self.setup
      return true if exists?
      FileUtils.mkdir_p(DIRECTORY_PATH)
      new({}).write
    end

    def self.from_yaml(yaml)
      return self.new(YAML.load(yaml)[SERIALIZATION_KEY])
    end

    def self.load
      self.setup unless self.exists?
      return self.from_yaml(File.read(FILE_PATH))
    end

    def to_yaml()
      return YAML.dump({SERIALIZATION_KEY => @entries})
    end

    def write
      File.open(FILE_PATH, 'w') do |file|
        file.write(self.to_yaml)
      end
      true
    end
  end
end

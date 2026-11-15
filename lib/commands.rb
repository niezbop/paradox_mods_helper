#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'terminal-table'
require_relative 'paradox_mods_helper'

program :name, 'paradox_mods_helper'
program :version, ParadoxModsHelper::VERSION
program :description, 'TODO'

command :discover do |c|
  c.syntax = 'paradox_mods_helper discover [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Paradox_mods_helper::Commands::Discover
  end
end

command :list do |c|
  c.syntax = 'paradox_mods_helper list [options]'
  c.summary = 'List all mods currently discovered'
  c.description = ''
  c.action do |args, options|
    registry = ParadoxModsHelper::Registry.load()

    table = Terminal::Table.new(headings: %w[Identifier Name Path]) do |t|
      registry.entries.each do |entry|
        t << [entry[:identifier], entry[:name], entry[:path]]
      end
    end

    puts table
  end
end

command :deploy do |c|
  c.syntax = 'paradox_mods_helper deploy [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Paradox_mods_helper::Commands::Deploy
  end
end

command :clean do |c|
  c.syntax = 'paradox_mods_helper clean [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Paradox_mods_helper::Commands::Clean
  end
end


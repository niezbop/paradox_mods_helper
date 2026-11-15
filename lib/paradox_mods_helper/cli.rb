require 'commander/import'
require 'terminal-table'

program :name, File.basename($PROGRAM_NAME)
program :version, ParadoxModsHelper::VERSION
program :description, 'TODO'

command :discover do |c|
  c.syntax = 'paradox_mods_helper discover [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    if args.empty?
      say 'discover requires a PATH argument'
      exit(1)
    end

    registry = ParadoxModsHelper::Registry.load
    discover_path = File.expand_path(args[0])

    if File.file?(discover_path)
      # Read file to ensure it's a valid descriptor
      ParadoxModsHelper::Descriptor.from_file(discover_path)

      basename = File.basename(discover_path, File.extname(discover_path))

      identifier = if basename == 'descriptor'
                     File.basename(File.dirname(discover_path))
                   else
                     basename
                   end

      registry.add(identifier, discover_path)
      registry.write()
    else
      say "No file at path: #{discover_path}"
      exit(-1)
    end
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
      registry.entries.each do |identifier, path|
        descriptor = ParadoxModsHelper::Descriptor.from_file(path)

        t << [identifier, descriptor.name, path]
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


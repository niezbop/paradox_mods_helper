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
      if File.basename(discover_path) != 'descriptor.mod'
        say "Not a descriptor.mod file: #{discover_path}"
        exit(1)
      end

      # Read file to ensure it's a valid descriptor
      ParadoxModsHelper::Descriptor.from_file(discover_path)

      identifier = File.basename(File.dirname(discover_path))

      existing = registry.entries[identifier]
      status = registry.add(identifier, discover_path, overwrite: true)
      if status == :replaced
        say "Repointing #{identifier}: #{existing} → #{discover_path}"
      end
    elsif File.directory?(discover_path) && File.file?(File.join(discover_path, 'descriptor.mod'))
      descriptor_path = File.join(discover_path, 'descriptor.mod')

      # Read file to ensure it's a valid descriptor
      ParadoxModsHelper::Descriptor.from_file(descriptor_path)

      identifier = File.basename(discover_path)
      existing = registry.entries[identifier]
      status = registry.add(identifier, descriptor_path, overwrite: true)
      if status == :replaced
        say "Repointing #{identifier}: #{existing} → #{descriptor_path}"
      end
    elsif File.directory?(discover_path)
      Dir[File.join(discover_path, '*', 'descriptor.mod')].sort.each do |descriptor_path|
        # Skip subdirectories that are symlinks (e.g. a link pointing at a mod folder elsewhere)
        next if File.symlink?(File.dirname(descriptor_path))

        # Read file to ensure it's a valid descriptor
        ParadoxModsHelper::Descriptor.from_file(descriptor_path)

        name = File.basename(File.dirname(descriptor_path))

        status = registry.add(name, descriptor_path)
        if status == :conflict
          say "Skipping #{descriptor_path}: already registered at #{registry.entries[name]}"
        end
      end
    else
      say "No file at path: #{discover_path}"
      exit(-1)
    end

    registry.write
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


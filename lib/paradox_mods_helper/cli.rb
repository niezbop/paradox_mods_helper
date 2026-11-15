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
    elsif File.directory?(discover_path) && File.file?(File.join(discover_path, 'descriptor.mod'))
      descriptor_path = File.join(discover_path, 'descriptor.mod')

      # Read file to ensure it's a valid descriptor
      ParadoxModsHelper::Descriptor.from_file(descriptor_path)

      registry.add(File.basename(discover_path), descriptor_path)
    elsif File.directory?(discover_path)
      seen = {}

      Dir[File.join(discover_path, '*', '*.mod')].sort.each do |descriptor_path|
        # Skip subdirectories that are symlinks (e.g. Local_Mods -> game mod folder)
        next if File.symlink?(File.dirname(descriptor_path))

        name = File.basename(descriptor_path, '.mod')
        next if name == 'descriptor'

        content_path = File.join(File.dirname(descriptor_path), name)

        unless File.directory?(content_path)
          say "skipping #{descriptor_path}: no content directory at #{content_path}"
          next
        end

        if seen.key?(name)
          say "skipping #{descriptor_path}: mod name #{name} already found at #{seen[name]}"
          next
        end

        # Read file to ensure it's a valid descriptor
        ParadoxModsHelper::Descriptor.from_file(descriptor_path)

        seen[name] = descriptor_path
        registry.add(name, descriptor_path)
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


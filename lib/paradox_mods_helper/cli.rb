require 'colored2'
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

LIST_HEADING = %w[Identifier Name Version Path].map(&:bold)
command :list do |c|
  c.syntax = 'paradox_mods_helper list [options]'
  c.summary = 'List all mods currently discovered'
  c.description = ''
  c.action do |args, options|
    registry = ParadoxModsHelper::Registry.load()

    table = Terminal::Table.new(headings: LIST_HEADING) do |t|
      registry.entries.each do |identifier, path|
        descriptor = ParadoxModsHelper::Descriptor.from_file(path)

        t << [identifier, descriptor.name, descriptor.version, path]
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
  c.option '-T', '--target PATH', 'Target game mods directory to deploy into'
  c.action do |args, options|
    target = ParadoxModsHelper::Target.resolve(options.target)

    registry = ParadoxModsHelper::Registry.load
    identifiers = args.empty? ? registry.entries.keys : args

    FileUtils.mkdir_p(target)

    identifiers.each do |identifier|
      descriptor_path = registry.entries[identifier]

      if descriptor_path.nil?
        say "Skipping #{identifier}: not in registry"
        next
      end

      begin
        content_path = File.dirname(descriptor_path)
        raw = File.read(descriptor_path)

        deployed = if raw.match?(/path=".+"/)
                     raw.gsub(/path=".+"/, %Q{path="#{content_path}"})
                   else
                     base = raw.end_with?("\n") ? raw : "#{raw}\n"
                     "#{base}path=\"#{content_path}\"\n"
                   end

        File.write(File.join(target, "#{identifier}.mod"), deployed)
        say "Deployed #{identifier} to #{target}"
      rescue StandardError => e
        say "Deploy failed for #{identifier}: #{e.message}"
      end
    end
  end
end

command :clean do |c|
  c.syntax = 'paradox_mods_helper clean [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '-T', '--target PATH', 'Target mod directory to clean'
  c.action do |args, options|
    target = ParadoxModsHelper::Target.resolve(options.target)

    registry = ParadoxModsHelper::Registry.load
    identifiers = args.empty? ? registry.entries.keys : args

    identifiers.each do |identifier|
      descriptor_path = File.join(target, "#{identifier}.mod")
      stale_folder = File.join(target, identifier)

      begin
        removed = false

        if File.file?(descriptor_path)
          File.delete(descriptor_path)
          say "Removed #{descriptor_path}"
          removed = true
        end

        if File.directory?(stale_folder)
          FileUtils.rm_rf(stale_folder)
          say "Removed #{stale_folder}"
          removed = true
        end

        say "Nothing to clean for #{identifier}" unless removed
      rescue StandardError => e
        say "Clean failed for #{identifier}: #{e.message}"
      end
    end
  end
end

default_command :help

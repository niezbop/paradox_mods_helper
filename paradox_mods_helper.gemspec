# frozen_string_literal: true

require_relative 'lib/paradox_mods_helper/version'

Gem::Specification.new do |spec|
  spec.name = 'paradox_mods_helper'
  spec.version = ParadoxModsHelper::VERSION
  spec.authors = ['Paul Niezborala']
  spec.email = ['paulniezbo@gmail.com']

  spec.summary = 'A small toolkit for Paradox Interactive game modders'
  spec.description = 'paradox_mods_helper is a toolkit for modders who work on mods for games from Paradox Interactive. It assists in managing your local mods, keeping track of them and preparing them for deployment.'
  spec.homepage = 'https://github.com/niezbop/paradox_mods_helper'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/niezbop/paradox_mods_helper'
  spec.metadata['changelog_uri'] = 'https://github.com/niezbop/paradox_mods_helper/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'commander', '~> 6.0.0'
  spec.add_dependency 'terminal-table', '~> 4.0.0'

  # spec.add_development_dependency

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

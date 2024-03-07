# frozen_string_literal: true

require_relative "lib/bemi/version"

Gem::Specification.new do |spec|
  spec.name = "bemi-rails"
  spec.version = Bemi::VERSION
  spec.authors = ["exAspArk"]
  spec.email = ["exaspark@gmail.com"]

  spec.summary = "Automatic data change tracking for Ruby on Rails."
  spec.description = "Automatic data change tracking for Ruby on Rails."
  spec.homepage = "https://github.com/BemiHQ/bemi-rails"
  spec.license = "LGPL-3.0"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BemiHQ/bemi-rails"
  spec.metadata["changelog_uri"] = "https://github.com/BemiHQ/bemi-rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "railties", ">= 6.0.0"
  spec.add_dependency "activerecord", ">= 6.0.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

Gem::Specification.new do |spec|
  spec.name = "lumberjack_data_dog_device"
  spec.version = File.read(File.join(__dir__, "VERSION")).strip
  spec.authors = ["Brian Durand"]
  spec.email = ["bbdurand@gmail.com"]

  spec.summary = "A logging device for sending logs to DataDog in JSON format."
  spec.homepage = "https://github.com/bdurand/lumberjack_data_dog_device"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  ignore_files = %w[
    .gitignore
    .travis.yml
    Appraisals
    Gemfile
    Gemfile.lock
    Rakefile
    gemfiles/
    spec/
  ]
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| ignore_files.any? { |path| f.start_with?(path) } }
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "lumberjack_json_device", ">=1.0"

  spec.add_development_dependency("rspec", ["~> 3.0"])
  spec.add_development_dependency "rake"
end

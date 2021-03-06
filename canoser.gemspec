
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "canoser/version"

Gem::Specification.new do |spec|
  spec.name          = "canoser"
  spec.version       = Canoser::VERSION
  spec.authors       = ["yuan xinyu"]
  spec.email         = ["yuanxinyu.hangzhou@gmail.com"]

  spec.summary       = %q{A ruby implementation of the canonical serialization for the Libra network.}
  spec.description   = %q{A ruby implementation of the canonical serialization for the Libra network. Canonical serialization guarantees byte consistency when serializing an in-memory data structure. It is useful for situations where two parties want to efficiently compare data structures they independently maintain. It happens in consensus where independent validators need to agree on the state they independently compute. A cryptographic hash of the serialized data structure is what ultimately gets compared. In order for this to work, the serialization of the same data structures must be identical when computed by independent validators potentially running different implementations of the same spec in different languages.}
  spec.homepage      = "https://github.com/yuan-xy/canoser-ruby.git"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/yuan-xy/canoser-ruby.git"
    spec.metadata["changelog_uri"] = "https://github.com/yuan-xy/canoser-ruby/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug", "~> 11.0"

end

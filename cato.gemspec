lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cato/version"

Gem::Specification.new do |spec|
  spec.name    = "cato"
  spec.version = Cato::VERSION
  spec.authors = ["Benjamin Ragheb"]
  spec.email   = ["ben@logcheck.com"]

  spec.summary = "Cato provides Rake tasks for managing Xcode dependencies"

  spec.description = <<DESCRIPTION
Cato makes it easy to manage your Xcode project's dependencies using
Rake (a Make-like dependency management tool implemented in Ruby).

Cato unobtrusively downloads, builds, and copies static libraries and
frameworks into the places where Xcode expects to find them.
DESCRIPTION

  spec.homepage = "https://github.com/logcheck/cato"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    reject_pattern = %r{^(test|spec|features)/}
    `git ls-files -z`.split("\x0").reject { |f| f.match(reject_pattern) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # macOS 13.2.1 includes CFPropertyList 2.3.6.
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "CFPropertyList", "~> 2.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

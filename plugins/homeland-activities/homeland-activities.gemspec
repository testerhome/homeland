require_relative "lib/homeland/activities/version"

Gem::Specification.new do |spec|
  spec.name        = "homeland-activities"
  spec.version     = Homeland::Activities::VERSION
  spec.authors     = ["atpking"]
  spec.email       = ["atpking@gmail.com"]
  spec.homepage    = "https://testerhome.com"
  spec.summary     = "Summary of Homeland::Activities."
  spec.description = "Description of Homeland::Activities."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3", ">= 6.1.3"
  spec.add_dependency "groupdate", "~> 5.2"
end

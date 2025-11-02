Pod::Spec.new do |s|
  s.name        = "LoggerFactory"
  s.version     = "1.1.5"
  s.summary     = "A library for logging in macOS platform."
  s.homepage    = "https://github.com/kelvinjjwong/LoggerFactory"
  s.license     = { :type => "MIT" }
  s.authors     = { "kelvinjjwong" => "kelvinjjwong@outlook.com" }

  s.requires_arc = true
  s.swift_version = "5.0"
  s.osx.deployment_target = "10.15"
  s.source   = { :git => "https://github.com/kelvinjjwong/LoggerFactory.git", :tag => s.version }
  s.source_files = "Sources/LoggerFactory/**/*.swift"
end

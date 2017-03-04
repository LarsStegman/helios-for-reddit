Pod::Spec.new do |s|
  s.name         = "Helios"
  s.version      = "0.0.1"
  s.summary      = "A Reddit library in Swift."
  s.description  = <<-DESC
A Reddit client in Swift. This framework does not allow the use of the Reddit api without using OAuth2.                   
DESC
  s.homepage     = "https://github.com/LarsStegman/helios-for-reddit"
  s.license      = "MIT"
  s.author    = "Lars Stegman"
  s.social_media_url   = "http://twitter.com/LarsSteg"
  s.source       = { :git => 'https://github.com/LarsStegman/helios-for-reddit.git', :branch => 'master', :tag => "v#{s.version.to_s}" }
  s.source_files  = "Sources/**/*.swift"
  s.ios.deployment_target = '10.0'
  s.framework = 'Security'
end

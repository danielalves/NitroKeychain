Pod::Spec.new do |s|
  s.name             = "NitroKeychain"
  s.version          = "1.0.0"
  s.summary          = "Apple's keychain without pain."
  s.description      = <<-DESC
                       NitroKeychain is a thin, yet powerful, abstraction layer on top of iOS keychain that 
                       provides commonly needed features.
                       DESC
  s.homepage         = "https://github.com/danielalves/NitroKeychain"
  s.license          = 'MIT'
  s.author           = { "globo.tv app team" => "globo.tv.app@corp.globo.com" }
  s.source           = { :git => "https://github.com/danielalves/NitroKeychain.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'
  s.frameworks   = 'Security'
end

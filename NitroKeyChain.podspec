Pod::Spec.new do |s|
  s.name             = "NitroKeyChain"
  s.version          = "1.0.0"
  s.summary          = "Apple's keychain without pain."
  s.description      = <<-DESC
                       NitroKeychain is an iOS library to store and load items from keychain easily. 
                       DESC
  s.homepage         = "https://github.com/danielalves/NitroKeyChain"
  s.license          = 'MIT'
  s.author           = { "globo.tv app team" => "globo.tv.app@corp.globo.com" }
  s.source           = { :git => "https://github.com/danielalves/NitroKeyChain.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'
  s.frameworks   = 'Security'
end

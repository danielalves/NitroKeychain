Pod::Spec.new do |s|
  s.name             = 'NitroKeychain'
  s.version          = '1.0.0'
  s.summary          = "Apple's keychain without pain."
  s.description      = <<-DESC
                       NitroKeychain is a thin, yet powerful, abstraction layer on top of iOS keychain that 
                       provides commonly needed features.
                       DESC
  s.homepage         = 'https://github.com/danielalves/NitroKeychain'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = 'Daniel L. Alves', 'Gustavo Barbosa'
  s.social_media_url = 'http://twitter.com/alveslopesdan'
  s.social_media_url = 'http://twitter.com/gustavocsb'
  s.source           = { :git => 'https://github.com/danielalves/NitroKeychain.git', :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.source_files = 'NitroKeychain/NitroKeychain'
  s.requires_arc = true
  s.frameworks   = 'Security'
end

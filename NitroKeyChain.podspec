Pod::Spec.new do |s|
  s.name             = "NitroKeyChain"
  s.version          = "0.1.0"
  s.summary          = "A short description of NitroKeyChain."
  s.description      = <<-DESC
                       An optional longer description of NitroKeyChain

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
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

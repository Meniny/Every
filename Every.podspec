Pod::Spec.new do |s|
  s.name             = "Every"
  s.version          = "1.0.0"
  s.summary          = "Elegant Timer in Swift"

  s.homepage         = "https://github.com/Meniny/Every"
  s.license          = 'MIT'
  s.author           = { "Elias Abel" => "Meniny@qq.com" }
  s.source           = { :git => "https://github.com/Meniny/Every.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Every/**/*'
  # s.public_header_files = 'Every/**/*.h'
  s.ios.frameworks = 'Foundation'
  s.osx.frameworks = 'Cocoa'
  s.tvos.frameworks = 'Foundation'
  s.watchos.frameworks = 'Foundation'
end


Pod::Spec.new do |s|
  s.name         = "JwtUtils"
  s.version      = "1.0.0"
  s.summary      = "JwtUtils"
  s.description  = <<-DESC
                  JwtUtils
                   DESC
  s.homepage     = "https://github.com/codeforpublic/react-native-jwt-utils.git"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "sittiphol@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/codeforpublic/react-native-jwt-utils.git", :tag => "master" }
  s.source_files = "ios/**/*.{h,m}"
  s.vendored_frameworks = 'ios/secp256k1.framework'
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
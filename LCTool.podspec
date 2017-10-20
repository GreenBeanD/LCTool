Pod::Spec.new do |s|
  s.name         = "LCTool"
  s.version      = "1.0"
  s.summary      = "Some encapsulation about Alamofire, FMDB and so on."
  s.homepage     = "https://github.com/GreenBeanD/LCTool"
  s.license      = "MIT"
  s.author       = { "lazyCat" => "dxyrainbow@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/GreenBeanD/LCTool.git"， :tag => s.version }
  s.requires_arc = true
  s.source_files  = "LCTool/LCTool/LCTool/**/*.{swift}"
  s.dependency   = 'Alamofire'
  s.dependency   = 'FMDB'
end

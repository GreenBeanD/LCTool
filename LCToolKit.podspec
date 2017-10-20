Pod::Spec.new do |s|
    s.name         = 'LCToolKit'
    s.version      = '1.0.1'
    s.summary      = 'Some encapsulation about Alamofire, FMDB and so on.'
    s.homepage     = 'https://github.com/GreenBeanD/LCTool'
    s.license      = 'MIT'
    s.authors      = {'LazyCat' => 'dxyrainbow@163.com'}
    s.platform     = :ios, '6.0'
    s.source       = {:git => 'https://github.com/GreenBeanD/LCTool.git', :tag => s.version }
    s.source_files = 'LCToolKit/**/*.{swift}'
    s.framework  = 'UIKit'
    s.dependency  'Alamofire','~> 4.5.1'
    s.dependency  'FMDB','~> 2.7.2'
    s.requires_arc = true
end

Pod::Spec.new do |s|
    s.name             = 'Tenta'
    s.version          = '0.5.0'
    s.summary          = 'Property based testing made easy'
    s.description      = 'Simple property based testing library for swift'
    s.swift_version    = '5.1'
    s.homepage         = 'https://github.com/niilohlin/Tenta'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'niilohlin' => 'niilohlin@gmail.com' }
    s.source           = { :git => 'https://github.com/niilohlin/Tenta.git', :tag => s.version.to_s }
    s.ios.deployment_target = '11.0'
    s.source_files = 'Tenta/**/*.{swift,plist}', 'Tenta-iOS/**/*.{swift}'
    s.resources = 'Tenta/*.txt'
    s.frameworks   = 'XCTest','UIKit','Foundation'
end

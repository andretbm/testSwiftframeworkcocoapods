Pod::Spec.new do |s|
  s.name         = 'testSwiftframework'
  s.version      = '1.0.0.2'
  s.summary      = 'SurveyPlugin'
  s.homepage   = 'https://github.com/andretbm/testSwiftframeworkcocoapods.git'
  s.description  = <<-DESC
                   Ignidata SurveyPlugin

		   DESC

s.license = {:type => 'MIT',:text => <<-LICENSE
Copyright 2015 Ignidata
LICENSE
}
s.source_files          = '*.framework'
s.platforms             = { :ios => '8.0' }
s.ios.deployment_target = '8.0'
s.author            = {
'andretbm' => 'andremuchagata@gmail.com'
}

s.platform     = :ios
s.source       = { :git => 'https://github.com/andretbm/testSwiftframeworkcocoapods.git', :tag => '1.0.0.2' }
s.source_files  = '*.framework'

s.requires_arc = true
end

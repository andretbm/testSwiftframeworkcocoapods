Pod::Spec.new do |s|
  s.name         = 'testSwiftframework'
  s.version      = '1.0.0.0'
  s.summary      = 'SurveyPlugin'
  s.homepage   = 'https://github.com/andretbm/testSwiftframeworkcocoapods.git'
  s.description  = <<-DESC
                   Ignidata SurveyPlugin

		   DESC

s.license = {:type => 'MIT',:text => <<-LICENSE
Copyright 2015 Ignidata
LICENSE
}
s.author            = {
'andretbm' => 'andremuchagata@gmail.com'
}

  s.platform     = :ios
s.source       = { :git => 'https://github.com/andretbm/testSwiftframeworkcocoapods.git', :tag => s.version }
  s.source_files  = '*.swift'
  s.public_header_files = 'IGMainViewController.swift'
  s.requires_arc = true
end

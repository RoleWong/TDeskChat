Pod::Spec.new do |spec|
  spec.name         = 'TDeskChat'
  spec.version      = '2.1.1'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIChat'
  
  
#  spec.vendored_frameworks = 'ReactiveObjCForTDesk.framework'
  
  spec.dependency 'TDeskCore', '~> 2.1.0'
  spec.dependency 'TDeskCommon', '~> 2.1.0'
  spec.dependency 'SDWebImage'
  spec.dependency 'ReactiveObjCForTDesk'
  
  spec.requires_arc = true

  spec.source = { :git => 'https://github.com/RoleWong/TDeskChat.git', :tag => spec.version}
  spec.source_files = '**/*.{h,m,mm,c}'
  spec.resource = ['Resources/*.bundle']
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'Resources/PrivacyInfo.xcprivacy'
  }
end

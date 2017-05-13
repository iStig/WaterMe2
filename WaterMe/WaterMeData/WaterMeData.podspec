
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "WaterMeData"
  s.version      = "1.0.0"
  s.summary      = "WaterMe Realm Data Components."
  s.description  = "WaterMe Realm Data Components."
  s.homepage     = "www.saturdayapps.com"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "GPLv3"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "jeffreybergier" => "jeffburg@jeffburg.com" }
  s.social_media_url   = "http://twitter.com/jeffburg"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.platform     = :ios
  s.ios.deployment_target = "10.3"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/jeffreybergier/WaterMe2.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = "Source"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.dependency 'RealmSwift'
  s.dependency 'XCGLogger', '~> 5.0.1'

end

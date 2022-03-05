# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'M.A.H' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
pod 'Firebase/Core'
pod 'Alamofire', '~> 4.7'
pod 'AlamofireImage', '~> 3.1'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Analytics'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'SwiftyGif'
pod 'Giphy'
pod 'SwiftyJSON', '~> 4.0'
pod 'SideMenu', '~> 6.0'
  # Pods for M.A.H

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

end


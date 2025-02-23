//
//  AppDelegate.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 6/27/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, MessagingDelegate {

    var window: UIWindow?
}

extension AppDelegate : UIApplicationDelegate {

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]){
//            granted, _ in
//            guard granted else {return}
//            DispatchQueue.main.async {
//                application.registerForRemoteNotifications()
//            }
//        }
        FirebaseApp.configure()

        if Auth.auth().currentUser != nil {

            loadMainScreen(window: window!)
        } else {

            loadLoadLoginScreen(window: window!)
        }
        Messaging.messaging().delegate = self
        

//        InstanceID.instanceID().instanceID { (result, error) in
//          if let error = error {
//            print("Error fetching remote instance ID: \(error)")
//          } else if let result = result {
//            print("Remote instance ID token: \(result.token)")
////            self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
//
//          }
//        }

        return true
    }
     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(fcmToken)")

      let dataDict:[String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
        let userDefaults = UserDefaults.standard


        if let savedToken = userDefaults.string(forKey: fcmToken!) {
            print("Token has not changed. it is \(fcmToken)")
        } else {
            //update token in database
            userDefaults.set(fcmToken, forKey: "\(fcmToken)")
            FirebaseController.instance.updateThisUserToken(fcmToken!)
            print("Token has changed. it is \(fcmToken)")
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x",$1)}
        print(token, 5000, deviceToken.base64EncodedString())
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }

      // Print full message.
      print("USER INFO FROM APP DELEGATE",userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

//      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    func loadMainScreen(window:UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as? UINavigationController ?? UINavigationController()
        let mainVC = storyboard.instantiateViewController(withIdentifier: "StartGame")
        navigationController.viewControllers = [mainVC]
        window.rootViewController = navigationController

       window.makeKeyAndVisible()

    }


func loadLoadLoginScreen(window:UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as? UINavigationController ?? UINavigationController()
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login")
        navigationController.viewControllers = [loginVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.

    }

}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var mainNavigationController: MainNavigationController {
        return MainNavigationController()
    }

}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
 
//    // Print full message.
//    print(userInfo, #function)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound, .badge]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
defer { completionHandler() }
    guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
    let payload = response.notification.request.content
    if let _ = payload.userInfo["ToLobby"] {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Lobby")
        vc.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(vc, animated: true) 
    }
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.

    // Print full message.
    print(userInfo, #function)
  }
}

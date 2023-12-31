//
//  AppDelegate.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/04.
//

import UIKit
import FirebaseCore
import UserNotifications
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
//        attemptToRegisterForNotifications(application: application)
        
        return true
    }
//    func attemptToRegisterForNotifications(application: UIApplication) {
//
////        Messaging.messaging().delegate = self
//
//        UNUserNotificationCenter.current().delegate = self
//
//        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: options) { authorized, error in
//
//            if authorized {
//                print("SUCCESSFULLY REGISTERED FOR NOTIFICATIONS")
//            }
//            DispatchQueue.main.async {
//                application.registerForRemoteNotifications()
//            }
//        }
//    }
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("DEGUG: Registered for notifications with device token: ", deviceToken)
//    }
    
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let fcmToken = fcmToken else { return }
//        print("DEBUG: Registered with FCM Token: ", fcmToken)
//    }
    
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


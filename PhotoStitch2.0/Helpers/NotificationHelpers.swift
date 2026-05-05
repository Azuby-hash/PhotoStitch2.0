//
//  MNotification.swift
//  PushUpCounter
//
//  Created by TapUniverse Dev9 on 5/12/25.
//

import UIKit

/**
 Apple Push Notification Services config
 
 Step 1: https://developer.apple.com: Developer -> Identifiers -> <AppID> -> Push Notifications (no need config)
 Step 2: https://developer.apple.com: Keys -> Create key with APN
 Step 3: Xcode: Target -> Signing and Capabilities -> + Capability -> Push Notifications
 Step 4: VSCode: Run node-apn, but recommend rewrite for secure
 */
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print(error)
    }
}

/**
 Apple Push Notification Services config
 
 Step 1: https://developer.apple.com: Developer -> Identifiers -> <AppID> -> Push Notifications (no need config)
 Step 2: https://developer.apple.com: Keys -> Create key with APN
 Step 3: Xcode: Target -> Signing and Capabilities -> + Capability -> Push Notifications
 Step 4: VSCode: Run node-apn, but recommend rewrite for secure
 */
class NotificationHelpers {
    /** Every notification type need this */
    static func requestForPushNotification(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            completion(granted)
            
            if let error = error {
                print(error)
            }
        })
    }
    
    /** Register for remote notification from APNs and our server */
    static func registerForRemoteNotification(success: @escaping () -> Void, failed: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            guard settings.authorizationStatus == .authorized else {
                print("authorizations status is failed.")
                
                failed?()
                
                return
            }
            
            UIApplication.shared.registerForRemoteNotifications()
            
            success()
        })
    }
}

extension NotificationHelpers {
    /** Remove all schedule notifications */
    static func removeAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /** Remove schedule notification with id */
    static func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /**
     Add schedule notification
     - Parameters:
        - title: Title string
        - body: Description string
        - id: Identifity for specific event, no change
        - dateComponents: Date component use for calendar use
     */
    static func scheduleNotification(title: String, body: String, id: String, dateComponents: DateComponents, success: @escaping () -> Void, failed: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            guard settings.authorizationStatus == .authorized else {
                print("authorizations status is failed.")
                
                failed?()
                
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .defaultRingtone
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                print(requests)
            }
        })
    }
}

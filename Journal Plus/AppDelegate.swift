//
//  AppDelegate.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 05/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import UserNotifications
import WidgetKit

var mainWindow = UIWindow()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let journalURL = "journalPlus"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //extras baby
        Notifications.initialize()
        transferTitles()
        removeOldNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        mainWindow = window!
        mainWindow.tintColor = AppTintColor.value
        
        Notifications.requestAutharization()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void){
        
        func openAppToDate(){
            let myAppUrl = URL(string: "\(journalURL)://\(response.notification.date.code)")!
            UIApplication.shared.open(myAppUrl, options: [:], completionHandler: nil)
        }
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            openAppToDate()
        case Notifications.keys.addTitle:
            if let textInput = response as? UNTextInputNotificationResponse{
                titles[response.notification.date.toDay] = textInput.userText
            }
        case Notifications.keys.openApp:
            openAppToDate()
        case Notifications.keys.dismiss:
            break
        default:
            break
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if url.host == nil
        {
            return true;
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "://")
        let query = queryArray[1]
        
        if let day = query.optionalDay{
            selectDate(day: day)
        }
        
        return true
    }


}


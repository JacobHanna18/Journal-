//
//  Notifications.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 19/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import UserNotifications
import StoreKit

class Notifications{
    
    static func initialize () {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            Notifications.settings = settings
            Notifications.setNotification()
        }
    }
    
    static var settings : UNNotificationSettings?
    
    class Time : CodableSetting{
        static var last: DateComponents? = nil
        static let key = "notificationTimeBackUpKey2"
        static let defaultValue = DateComponents(hour : 23, minute : 30)
    }
    
    class On : KeyedSetting{
        static var last: Bool? = nil
        static let key = "notificationOnBackUpKey3"
        static let defaultValue = true
    }
    
    static func requestAutharization(completion : ((Bool) -> Void)? = nil){
        if settings?.authorizationStatus == UNAuthorizationStatus.notDetermined{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted, err) in
                On.value = granted
                setNotification()
            }
        }
    }
    
    static func setNotification(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [keys.notification])
        if On.value{
            createNotificationCategory()
            let content = UNMutableNotificationContent()
            content.title = "It's the time to add a title"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = keys.category
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Time.value, repeats: true)
            
            let request = UNNotificationRequest(identifier: keys.notification, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    struct keys{
        static let category = "NotificationCategory"
        static let addTitle = "AddTitleAcion"
        static let openApp = "OpenAppAction"
        static let dismiss = "DismissAction"
        
        static let notification = "AddNotification"
    }
    
    static func createNotificationCategory(){
        let addTitle = UNTextInputNotificationAction(identifier: keys.addTitle, title: "Add Title", options: [.authenticationRequired], textInputButtonTitle: "Add", textInputPlaceholder: "title")
        let openApp = UNNotificationAction(identifier: keys.openApp, title: "Open App", options: [.foreground])
        let dismiss = UNNotificationAction(identifier: keys.dismiss, title: "Dismiss", options: [])
        
        let category = UNNotificationCategory(identifier: keys.category, actions: [addTitle,openApp,dismiss], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

}

class Reminders : CodableSetting{
    static var last: [Reminder]? = nil
    static let key = "remindersArrayBackupKey"
    static let defaultValue : [Reminder] = []
    
    static var array : [Reminder]{
        
        Reminders.value = Reminders.value.filter { (r) -> Bool in
            return r.valid
        }
        
        return Reminders.value.sorted(by: { (r1, r2) -> Bool in
            r1 < r2
        })
    }
    
    static func add (reminder : Reminder){
        remove(reminder: reminder)
        Reminders.value.append(reminder)
    }
    
    static func remove (reminder : Reminder){
        Reminders.value.removeAll(where: {$0 == reminder})
    }
    
}

struct Time : Codable, Equatable {
    var h : Int
    var m : Int
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.h < rhs.h ? true : (lhs.h == lhs.h ? lhs.m < rhs.m : false )
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.h == rhs.h && lhs.m == rhs.m
    }
    
}


class Reminder : Codable, Comparable {
    
    var title : String
    var day : Day
    
    var time : Time
    
    var trigger : DateComponents{
        return DateComponents(year: day.y, month: day.m, day: day.d, hour: time.h, minute: time.m)
    }
    
    var code : String{
        return "\(day.d)-\(day.m)-\(day.y)-notificationId"
    }
    
    var toString : (ToString, ToString){
        return (title as ToString, day as ToString)
    }
    
    var valid : Bool {
        let date = Date()
        let day_ = date.toDay
        let time_ = Time(h: date.hour, m: date.minute)
        return day < day_ ? false : (day == day_ ? time_ < time : true)
    }
    
    init() {
        title = ""
        day = Day()
        time = Time(h: 23, m: 59)
    }
    
    func update(){
        
        Reminders.add(reminder: self)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.code])
        
        let content = UNMutableNotificationContent()
        content.title = self.title == "" ? "Journal! reminder" : self.title
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: self.trigger, repeats: false)
        
        let request = UNNotificationRequest(identifier: self.code, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func remove(){
        
        Reminders.remove(reminder: self)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.code])
    }
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.code == rhs.code
    }
    
    static func < (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.code < rhs.code
    }
    
    static let userInfo = "reminder"
}


func removeOldNotifications(){
    class OldNotificationStatus : KeyedSetting{
        static var last: Int? = nil
        static let key = "OldNotificationStatus"
        static let defaultValue = 0
    }
    
    if(OldNotificationStatus.value == 0){
        let arr = Reminders.value
        arr.forEach { (r) in
            r.remove()
        }
        arr.forEach { (r) in
            r.update()
        }
        OldNotificationStatus.value = 1
    }
}


class ActionCount : KeyedSetting{
    static var last: Int? = nil
    static let key = "ReviewWorthyActionCountKey1"
    static let defaultValue = 0
}

class LastVersion : KeyedSetting{
    static var last: String? = nil
    static let key = "LastVersionReviewedKey1"
    static let defaultValue = ""
    
}

func presentReview(){
    
    let minimumReviewWorthyActionCount = 3
    
    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: bundleVersionKey) as? String
    
    guard LastVersion.value == "" || LastVersion.value != currentVersion else {
        return
    }
    
    ActionCount.value += 1
    
    guard ActionCount.value >= minimumReviewWorthyActionCount else {
        return
    }
    
    SKStoreReviewController.requestReview()
    
    ActionCount.value = 0
    LastVersion.value = currentVersion ?? ""
}

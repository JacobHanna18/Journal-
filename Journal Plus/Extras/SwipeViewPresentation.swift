//
//  reminderVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 25/01/2019.
//  Copyright © 2019 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView

extension UIViewController{
    //add reminder
    func presentReminderView (_ r : Reminder){
        self.presentPointView(PointsList(points: { () -> [MainPoint] in
            let date = DataPoint<String>("Date",get: r.day.toString)
            let title = InputPoint<String>("Reminder Title", get: r.title, set: { (str) in
                r.title = str
                r.update()
            }, placeHolder: "reminder title")
            let time = DateInputPoint("Time of Reminder Delivery", get: Calendar.current.date(from: r.trigger), set: { (date) in
                r.time = Time(h: date.hour, m: date.minute)
                r.update()
            },mode: .time,minimum : nil)
            return [date,title,time]
        }, title: "Reminder", delete: {
            r.remove()
        }, .other("Remove", true)))
    }
    //expand title
    func presentExpandedView (_ day : Day){
        self.presentPointView(PointsList(points: { () -> [MainPoint] in
            return [
                LongInput<String>(day.toString, height: 500, background: AppTintColor.value.withAlphaComponent(0.1), get: titles[day,true], set: { (str) in
                    titles[day,true] = str
                })
            ]
        }, title: "Expanded Title", delete: {
            titles[day, true] = nil
        }, .other("Clear", true)))
    }
    //Present duplicate titles
    func presentDuplicate (_ days : [Day],title : String){
        
        let old : [(Day , String)] = days.map { (day) -> (Day, String) in
            return (day, titles[day] ?? "")
        }
        
        func getOld (day : Day) -> String{
            return (old.first { arg -> Bool in
                return arg.0 == day
            })?.1 ?? title
        }
        
        self.presentPointView(PointsList(points: { () -> [MainPoint] in
            return days.map { (day) -> MainPoint in
                return InputPoint<String>(day.toString, get: titles[day]?.lowercased() == getOld(day: day).lowercased() ? "" : titles[day],accessory: { () -> Bool in
                    TopSwipeView.view?.presentExpandedView(day)
                    return false
                }, set: { (str) in
                    if str == ""{
                        titles[day] = getOld(day: day)
                    }else{
                        titles[day] = str
                    }
                }, placeHolder: getOld(day: day))
            }
        }, title: "Duplicate Titles", delete: {}, .none))
    }
    
}

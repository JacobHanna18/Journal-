//
//  reminderVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 25/01/2019.
//  Copyright © 2019 Jacob Hanna. All rights reserved.
//

import UIKit

extension UIViewController{
    //add reminder
    func presentReminderView (_ r : Reminder){
        let date = FormCell(type: .StringSub2, title: "Date", get : {
            return r.day.toString
        })
        
        let title = FormCell(type: .StringInput, title: "Reminder Title") { (inp) in
            if let str = inp as? String{
                r.title = str
                r.update()
            }
        } get: { () -> Any in
            r.title
        }
        
        let time = FormCell(type: .DateInput(showTime: true, showDate: false), title: "Time of Reminder Delivery") { (inp) in
            if let date = inp as? Date{
                r.time = Time(h: date.hour, m: date.minute)
                r.update()
            }
        } get: { () -> Any in
            (Calendar.current.date(from: r.trigger)) ?? Date()
        }
        
        self.showForm { () -> FormProperties in
            return FormProperties(title: "Reminder", delete: {
                r.remove()
            }, cells: [date,title,time], button: .init(label: "Remove", showAlert: true))
        }
    }
    //expand title
    func presentExpandedView (_ day : Day){
        
        let storyBoard: UIStoryboard = self.storyboard!
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "fillVCID") as! fullVC
        newViewController.day = day
        newViewController.presenting = self as? Presenting
        let navC = UINavigationController(rootViewController: newViewController)
        self.present(navC, animated: true, completion: nil)
        return
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
        
        self.showForm { () -> FormProperties in
            let dayCells = days.map { (day) -> FormCell in
                return FormCell(type: .StringInput, title: day.toString) { (inp) in
                    if let str = inp as? String{
                        if str == ""{
                            titles[day] = getOld(day: day)
                        }else{
                            titles[day] = str
                        }
                    }
                } get: { () -> Any in
                    return (titles[day]?.lowercased() == getOld(day: day).lowercased() ? "" : titles[day]) ?? ""
                }
            }
            return FormProperties(title: "Duplicate Titles", cells: dayCells, button: .none)
        }
        //form view start
        /*
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
 */
    }
    
}

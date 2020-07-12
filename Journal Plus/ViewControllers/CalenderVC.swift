//
//  ViewController.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 05/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import StoreKit
import SwipeView

var tabBar = UITabBarController()

let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

class CalenderVC: UIViewController, CalenderDelegate, UITextFieldDelegate, Reloadable {
     @IBOutlet weak var titleTF: UITextField!
     @IBOutlet weak var prevButton: UIButton!
     @IBOutlet weak var nextButton: UIButton!
     @IBOutlet weak var calender: CalendarView!
     
     @IBOutlet weak var monthButton: UIButton!
     
     
     @IBOutlet weak var expandButton: UIButton!
     
     var keyboardShowing = false
     
     @IBOutlet weak var calenderFromBottom: NSLayoutConstraint!
     @IBOutlet weak var selectedDateButton: UIButton!
     
     override func viewWillAppear(_ animated: Bool) {
          setDateLabel()
          Titles.reload()
          reload()
          expandButtonReload()
          titleTF.autocapitalizationType = Capitalize.value ? .words : .none
          
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          tabBar = self.tabBarController!
          calender.calenderDelegate = self
          calender.select(day: Day())
          monthChanged(month: calender.month, year: calender.year, type: .random)
          
          
          NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
               self.keyboardShowing = false
               self.expandButtonReload()
               if let userInfo = notification.userInfo {
                    let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                    let endFrameY = endFrame?.origin.y ?? 0
                    let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    if endFrameY >= UIScreen.main.bounds.size.height {
                         self.calenderFromBottom.constant = 0.0
                    } else {
                         self.calenderFromBottom.constant = endFrame?.size.height ?? 0.0
                    }
                    UIView.animate(withDuration: duration,delay: TimeInterval(0),options: animationCurve,animations: {
                         self.reload()
                         self.view.layoutIfNeeded()
                         
                    },completion: nil)
               }
          }
          NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
               self.keyboardShowing = true
               self.expandButtonReload()
               
               if let userInfo = notification.userInfo {
                    let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                    let endFrameY = endFrame?.origin.y ?? 0
                    let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    if endFrameY >= UIScreen.main.bounds.size.height {
                         self.calenderFromBottom.constant = 0.0
                    } else {
                         self.calenderFromBottom.constant = (endFrame?.size.height)! - (self.tabBarController?.tabBar.frame.height)!
                    }

                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: {
                                        self.reload()
                                        self.view.layoutIfNeeded()
                                        
                    },
                                   completion: nil)
               }
          }
          
     }
     
     @IBAction func titleChanged(_ sender: Any) {
          titles[calender.selectedDay] = titleTF.text
     }
     @IBAction func prevMonth(_ sender: Any) {
          calender.prevMonth()
     }
     @IBAction func nextMonth(_ sender: Any) {
          calender.nextMonth()
     }
     @IBAction func expandTitle(_ sender: Any) {
          if calender.selectedDay.enabled{
               self.presentExpandedView(calender.selectedDay)
          }else{
               let r = Reminder()
               r.day = calender.selectedDay
               r.time = Time(h : Date().hour, m : Date().minute)
               self.presentReminderView(r)
          }
          
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          presentDuplicateAlert(day: calender.selectedDay)
          presentReview()
          return true
     }
     
     func dayChanged(day: Day, old: Day, onCalender : Bool){
          
          if(onCalender && old == day && day.enabled){
               self.presentExpandedView(day)
          }
          
          if keyboardShowing{
               presentDuplicateAlert(day: old)
          }
          
          setDateLabel()
          if day.enabled{
               titleTF.isEnabled = true
               titleTF.text = titles[day]
               titleTF.placeholder = "title"
          }else{
               titleTF.isEnabled = false
               titleTF.text = nil
               titleTF.placeholder = "future date"
          }
          
          expandButtonReload()
          
     }
     
     func presentDuplicateAlert (day: Day){
          if let title = titles[day]{
               _ = Titles.checkDuplicates(title: title) { (arr) in
                    self.presentDuplicate(arr, title: title)
               }
          }
     }
     
     func monthChanged(month: Int, year: Int, type: MonthChangeType) {
          monthButton.setTitle("\(months[calender.month-1]) \(calender.year)", for: .normal)
          switch type {
          case .next:
               nextButton.alpha = 0
               UIView.animate(withDuration: 0.75) {
                    self.nextButton.alpha = 1
               }
          case .prev:
               prevButton.alpha = 0
               UIView.animate(withDuration: 0.75) {
                    self.prevButton.alpha = 1
               }
               
          default: break
          }
          
     }

     @IBAction func selectedDateTapped(_ sender: Any) {
          self.presentPointView(PointsList(points: { () -> [MainPoint] in
               return [
                    DataPoint<String>("Today",tap: { () -> Bool in
                         self.calender.select(day: Day())
                         return true
                    }),
                    DateInputPoint("Select Date", get: self.calender.selectedDay.toDate, set: { (date) in
                         self.calender.select(day: date.toDay)
                    }, mode: .date, minimum: nil),
                    DataPoint<String>("Random Title",tap: { () -> Bool in
                         self.calender.select(day: Titles.array.randomElement()?.0 ?? Day())
                         return true
                    })
               ]
          }, title: "Choose Day", delete: {}, .none))
     }
     
     func reload(){
          titleTF.text = titles[calender.selectedDay]
          calender.reloadData()
     }
     
     func setDateLabel(){
          selectedDateButton.setTitle(calender.selectedDay.toString, for: .normal)
     }
     
     func highlighted(day: Day) -> Bool {
          return Titles.contains(day)
     }
     func indecator(day: Day) -> Bool {
          return Titles.extented(day: day)
     }
     func expandButtonReload(){
          expandButton.isHidden = calender.selectedDay.enabled ? (ExtendButton.value ? false : !keyboardShowing )  : false
          expandButton.setTitle(calender.selectedDay.enabled ? "Expand Title" : "Add Reminder", for: .normal)
     }
     @IBAction func monthTapped(_ sender: Any) {
          selectedDateTapped(sender)
     }
     
}

func selectDate (day : Day){
     ((tabBar.viewControllers?[0] as? UINavigationController)?.topViewController as? CalenderVC)?.calender.select(day: day)
     tabBar.selectedIndex = 0
}

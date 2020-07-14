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

class CalenderVC: UIViewController, CalenderDelegate, UITextFieldDelegate, Reloadable {
     @IBOutlet weak var titleTF: UITextField!
     @IBOutlet weak var prevButton: UIButton!
     @IBOutlet weak var nextButton: UIButton!
     @IBOutlet weak var calenderView: CalendarView!
     
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
          calenderView.calenderDelegate = self
          calenderView.select(day: Day())
          monthChanged(calender: calenderView.calender, type: .random)
          
          
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
          titles[calenderView.selectedDay] = titleTF.text
     }
     @IBAction func prevMonth(_ sender: Any) {
          calenderView.prevMonth()
     }
     @IBAction func nextMonth(_ sender: Any) {
          calenderView.nextMonth()
     }
     @IBAction func expandTitle(_ sender: Any) {
          if calenderView.selectedDay.enabled{
               self.presentExpandedView(calenderView.selectedDay)
          }else{
               let r = Reminder()
               r.day = calenderView.selectedDay
               r.time = Time(h : Date().hour, m : Date().minute)
               self.presentReminderView(r)
          }
          
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          presentDuplicateAlert(day: calenderView.selectedDay)
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
     
     func monthChanged(calender : Calender, type: MonthChangeType) {
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
                         self.calenderView.select(day: Day())
                         return true
                    }),
                    DateInputPoint("Select Date", get: self.calenderView.selectedDay.toDate, set: { (date) in
                         self.calenderView.select(day: date.toDay)
                    }, mode: .date, minimum: nil),
                    DataPoint<String>("Random Title",tap: { () -> Bool in
                         self.calenderView.select(day: Titles.array.randomElement()?.0 ?? Day())
                         return true
                    })
               ]
          }, title: "Choose Day", delete: {}, .none))
     }
     
     func reload(){
          titleTF.text = titles[calenderView.selectedDay]
          calenderView.reloadData()
     }
     
     func setDateLabel(){
          selectedDateButton.setTitle(calenderView.selectedDay.toString, for: .normal)
     }
     
     func highlighted(day: Day) -> Bool {
          return Titles.contains(day)
     }
     func indecator(day: Day) -> Bool {
          return Titles.extented(day: day)
     }
     func expandButtonReload(){
          expandButton.isHidden = calenderView.selectedDay.enabled ? (ExtendButton.value ? false : !keyboardShowing )  : false
          expandButton.setTitle(calenderView.selectedDay.enabled ? "Expand Title" : "Add Reminder", for: .normal)
     }
     @IBAction func monthTapped(_ sender: Any) {
          selectedDateTapped(sender)
     }
     
}

func selectDate (day : Day){
     ((tabBar.viewControllers?[0] as? UINavigationController)?.topViewController as? CalenderVC)?.calenderView.select(day: day)
     tabBar.selectedIndex = 0
}

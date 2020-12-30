//
//  ViewController.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 05/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit

var tabBar = UITabBarController()

class CalenderVC: UIViewController, CalenderDelegate, UITextFieldDelegate, Presenting {
     
     
     @IBOutlet weak var titleTF: UITextField!
     
     @IBOutlet weak var expandButton: UIButton!
     @IBOutlet weak var mainView: UIView!
     
     var keyboardShowing : Bool{
          return titleTF.isFirstResponder
     }
     
     var content : UIHostingController<AnyView>!
     
     var calenderView : CalendarViewUI!
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
          
          self.tabBarController?.tabBar.items?[1].selectedImage = UIImage(systemName: Lists.TabBarSelectedImageName)?.withRenderingMode(.alwaysTemplate)
          self.tabBarController?.tabBar.items?[1].image = UIImage(systemName: Lists.TabBarImageName)?.withRenderingMode(.alwaysTemplate)
          tabBar = self.tabBarController!
          
          calenderView = CalendarViewUI(delegate: self)
          calenderView.delegate = self
          
          setContent()
          
     }
     
     func setContent(){
          content = UIHostingController(rootView: AnyView(calenderView.navigationBarHidden(true)))
         
         content.view.backgroundColor = UIColor.clear
         addChild(content)
         content.view.frame = mainView.frame
          mainView.addSubview(content.view)
         content.didMove(toParent: self)
         content.view.translatesAutoresizingMaskIntoConstraints = false
         content.view.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
         content.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
         content.view.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
         content.view.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
     }
     
     @IBAction func titleChanged(_ sender: Any) {
          titles[calenderView.selectedDay] = titleTF.text
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
     
     func textFieldDidBeginEditing(_ textField: UITextField) {
          expandButtonReload()
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          presentDuplicateAlert(day: calenderView.selectedDay)
          expandButtonReload()
          presentReview()
          return true
     }
     
     func dayChanged(day: Day, old: Day){
          
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
     
     func tapMonth() {
          selectedDateTapped(0)
     }
     
     func longHold(day: Day) {
          if day.enabled{
               self.presentExpandedView(day)
          }
     }
     
     func presentDuplicateAlert (day: Day){
          if let title = titles[day]{
               _ = Titles.checkDuplicates(title: title) { (arr) in
                    self.presentDuplicate(arr, title: title)
               }
          }
     }
     
     @IBAction func selectedDateTapped(_ sender: Any) {
          self.showForm { () -> FormProperties in
               FormProperties(title: "Choose Day", cells: [
                    FormCell(type: .StringTitle(), title: "Today", tap: {
                         self.calenderView.set(Day())
                         FormVC.top?.dismiss(animated: true, completion: nil)
                    }),
                    FormCell(type: .DateInput(showTime: false, showDate: true), title: "Select Date", set: { (inp) in
                         if let date = inp as? Date{
                              self.calenderView.set(date.toDay)
                         }
                         
                    }, get: { () -> Any in
                         self.calenderView.selectedDay.toDate
                    }),
                    FormCell(type: .StringTitle(), title: "Random Title", tap: {
                         self.calenderView.set(Titles.array.randomElement()?.0 ?? Day())
                         FormVC.top?.dismiss(animated: true, completion: nil)
                    })
               ], button: .none)
          }
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
     func indicator(day: Day) -> Bool {
          return Indicator.value ? Titles.extented(day: day) : false
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
     ((tabBar.viewControllers?[0] as? UINavigationController)?.topViewController as? CalenderVC)?.calenderView.set(day)
     tabBar.selectedIndex = 0
}

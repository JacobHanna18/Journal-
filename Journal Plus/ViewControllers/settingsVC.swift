//
//  settingsVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 06/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import UserNotifications
import SwipeView
import WidgetKit

class SettingsVC: UITableViewController{
    
    @IBOutlet weak var notificationCell: UITableViewCell!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var extendSwitch: UISwitch!
    @IBOutlet weak var indicatorSwitch: UISwitch!
    @IBOutlet weak var capitalizeSwitch: UISwitch!
    
    
    @IBOutlet weak var datePreview: UILabel!
    @IBOutlet weak var dateStyleSC: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePreview.text = Date().toString
        dateStyleSC.selectedSegmentIndex = DateStyle.styles.firstIndex(of: DateStyle.value)!
        checkNotificationAccess()
        extendSwitch.isOn = ExtendButton.value
        indicatorSwitch.isOn = Indicator.value
        capitalizeSwitch.isOn = Capitalize.value
    }
    

    
    @IBAction func dateStyleChanged(_ sender: Any) {
        DateStyle.value = DateStyle.styles[dateStyleSC.selectedSegmentIndex]
        datePreview.text = Date().toString
    }
    
    @IBAction func extendButtonChanged(_ sender: UISwitch) {
        ExtendButton.value = sender.isOn
    }
    
    @IBAction func indicatorChanged(_ sender: UISwitch) {
        Indicator.value = sender.isOn
    }
    @IBAction func capitalizeChanged(_ sender: UISwitch) {
        Capitalize.value = sender.isOn
    }
    
    @IBAction func notificationOnChanged(_ sender: UISwitch) {
        Notifications.On.value = sender.isOn
        Notifications.setNotification()
        
        if sender.isOn{
            presentTimePicker()
        }
    }
    
    func presentTimePicker(){
        self.presentPointView(PointsList(points: { () -> [MainPoint] in
            let date = Calendar.current.date(from: Notifications.Time.value)
            return[
                DateInputPoint("date", get: date, set: { (date) in
                    Notifications.Time.value = Calendar.current.dateComponents([.hour,.minute], from: date)
                    Notifications.setNotification()
                }, mode: .time, minimum: nil)
            ]
        }, title: "Notification Time", delete: {}, .none))
    }
    
    func presentColorPicker(){
        
        let lightArr = Icon.names.map { (name) -> UIImage in
            return UIImage(named: "\(name)@3x.png")!
        }
        let darkArr = Icon.names.map { (name) -> UIImage in
            return UIImage(named: "\(name)-DARK@3x.png")!
        }
        
        self.presentPointView(PointsList(points: { () -> [MainPoint] in
            let appIconPoints = [ImagePoint("Light App Icons", background: UIColor.white, text: UIColor.black, get: Icon.get(dark: false), set: { (index) in
                    Icon.setIcon(at: index, dark: false)
                    TopSwipeView.reload?()
                }, labels: lightArr, defaultIndex: 0),
                ImagePoint("Dark App Icons",background: UIColor.black, text: UIColor.white, get: Icon.get(dark: true), set: { (index) in
                    Icon.setIcon(at: index, dark: true)
                    TopSwipeView.reload?()
                }, labels: darkArr, defaultIndex: 0)
                
            ]
            
            var appColorPoint : [MainPoint] = [InputPoint<UIColor>("App Tint Color", get: AppTintColor.value, set: { (color) in
                AppTintColor.value = color
                TopSwipeView.view?.view.tintColor = color
            })]
            
            if #available(iOS 14.0, *) {
                let widgetStyle = [SelectionPoint("Widget Style", get: WidgetStyle.value, set: { (i) in
                    WidgetStyle.value = i
                }, labels: ["Match App","Match Icon"], defaultIndex: 0)]
                
                appColorPoint.insert(contentsOf: widgetStyle, at: 0)
            }
            
            return appColorPoint + (UIApplication.shared.supportsAlternateIcons ? appIconPoints : [])
        }, title: "Application Color", delete: {}, .none))
    }
    
    func checkNotificationAccess(){
        switch Notifications.settings!.authorizationStatus{
        case .authorized, .provisional, .ephemeral:
            notificationSwitch.isEnabled = true
            notificationSwitch.isOn = Notifications.On.value
        case .notDetermined:
            notificationSwitch.isOn = false
            notificationSwitch.isEnabled = false
            Notifications.requestAutharization(completion: { (granted) in
                self.checkNotificationAccess()
            })
        case .denied:
            notificationSwitch.isOn = false
            notificationSwitch.isEnabled = false
        @unknown default:
            print("unknown")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath)?.reuseIdentifier{
        case "SendRecieve" :
            tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(title: "Get Set", message: "Choose what action you want to take.\nMake sure you have read how the function works by clicking the i button.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Get", style: .default, handler: { (_) in
                do{
                    try GetSetTitles.get()
                }
                catch{
                    
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { (_) in
                do{
                    try GetSetTitles.set()
                }
                catch{
                    
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case "notificationCellID":
            if Notifications.On.value{
                presentTimePicker()
            }
        case "ColorSelectionCellID":
            presentColorPicker()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "SendRecieve"{
            let alert2 = UIAlertController(title: "Get Set Instructions", message: "When choosing [Get]], you'll get a text that represents your titles and copied into your device, you can send them where ever you want to be used by the [Set] button.\nWhen you've already copied the text, you can use [Set] to set your titles into this device, this may override you existing titles.", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert2, animated: true, completion: nil)
        }
    }
}

class ColorCell : UICollectionViewCell{
    @IBOutlet weak var circleView: UIView!
}

//
//  settingsVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 06/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import UserNotifications
import WidgetKit
import SwiftUI
import UniformTypeIdentifiers

class SettingsVC: UITableViewController, UIDocumentPickerDelegate, Presenting{
    func reload() {
        extendSwitch.onTintColor = AppTintColor.value
        indicatorSwitch.onTintColor = AppTintColor.value
        capitalizeSwitch.onTintColor = AppTintColor.value
        notificationSwitch.onTintColor = AppTintColor.value
    }
    
    
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
        
        reload()
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
        let dateCell = FormCell(type: .DateInput(showTime: true, showDate: false), title: "date") { (inp) in
            if let date = inp as? Date{
                Notifications.Time.value = Calendar.current.dateComponents([.hour,.minute], from: date)
                Notifications.setNotification()
            }
        } get: { () -> Any in
            return Calendar.current.date(from: Notifications.Time.value) ?? Date()
        }
        
        self.showForm { () -> FormProperties in
            return FormProperties(title: "Notification Time", cells: [dateCell], button: .none)
        }
    }
    
    func presentColorPicker(){
        
        self.showForm { () -> FormProperties in
            // app icon
            
            let appColorCell = FormCell(type: .ColorInput, title: "App Tint") { (inp) in
                if let color = inp as? Color{
                    AppTintColor.value = UIColor(color)
                    FormVC.top?.view.tintColor = UIColor(color)
                }
            } get: { () -> Any in
                return Color(AppTintColor.value)
            }
            
            let widgetStyle = FormCell(type: .SingleSelection(labels: ["Match App","Match Icon"]), title: "Widget Style") { (inp) in
                if let i = inp as? Int{
                    WidgetStyle.value = i
                }
            } get: { () -> Any in
                WidgetStyle.value
            }
            
            let lightArr = Icon.names.map { (name) -> Image in
                return Image(uiImage: UIImage(named: "\(name)@3x.png")!)
            }
            let darkArr = Icon.names.map { (name) -> Image in
                return Image(uiImage: UIImage(named: "\(name)-DARK@3x.png")!)
            }
            
            let icons = FormCell(type: .MatrixSelection(columns: 5, values: lightArr + darkArr), title: "App Icon") { (inp) in
                if let i = inp as? Int{
                    if i < lightArr.count{
                        Icon.setIcon(at: i, dark: false)
                    }else{
                        Icon.setIcon(at: i - lightArr.count, dark: true)
                    }
                }
            } get: { () -> Any in
                return 3
            }


            return FormProperties(title: "Application Color", cells: [widgetStyle,appColorCell,icons], button: .none)
        }
        
    }
    
    func shareFile(){
        do{
            let str = try GetSetTitles.get()
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let filename = (paths[0] as NSString).appendingPathComponent("MyJournal.\(GetSetTitles.fileExtension)")

                do {
                    try str.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)

                    let fileURL = NSURL(fileURLWithPath: filename)

                    let objectsToShare = [fileURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    FormVC.top?.present(activityVC, animated: true, completion: nil)

                } catch {
                    print("cannot write file")
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
        }catch{
            
        }
        
    }
    
    func setFromFile(){
        let selector = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: GetSetTitles.fileExtension)!], asCopy: true)
        selector.delegate = self
        FormVC.top?.present(selector, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        do{
            let file = try String(contentsOf: urls[0], encoding: String.Encoding.utf8)
            FormVC.top?.showForm({ () -> FormProperties in
                (GetSetTitles.formViewFromFileString(str: file) ?? FormProperties(title: "Error"))
            })
        }catch{
            print("")
        }
        
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
            showForm { () -> FormProperties in
                let note = FormCell(type: .StringTitle(), title: "This only saves the journal entries and not the done lists, if you want to save a done list, go to the done tab, edit the list you want to save then tap export.")
                let share = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.up"), title: "Export To File", tap:  {
                    self.shareFile()
                })
                let save = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.down"), title: "Import From File", tap:  {
                    self.setFromFile()
                })
                return FormProperties(title: "Import And Export", cells: [note, share,save], button: .none)
            }
            
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

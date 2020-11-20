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
            
            let lightArr = Icon.names.map { (name) -> UIImage in
                return UIImage(named: "\(name)@3x.png")!
            }
            let darkArr = Icon.names.map { (name) -> UIImage in
                return UIImage(named: "\(name)-DARK@3x.png")!
            }
            
            let lightIcons = FormCell(type: .ImageSelection(images: [lightArr,darkArr], background: [Color.white,Color.black], ringColor: [Color.black,Color.white]), title: "App Icon", divider: false) { (i) in
                if let index = i as? (Int,Int){
                    Icon.setIcon(at: index.0, dark: index.1 == 1)
                }
            } get: { () -> Any in
                return (Icon.Index.value,Icon.Dark.value ? 1 : 0)
            }


            return FormProperties(title: "Application Color", cells: [widgetStyle,appColorCell,lightIcons], button: .none)
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
            do{
                var (overwrite, new) = try GetSetTitles.set(str: file)
                
                let overwriteCell = FormCell(type: .StringTitle(systemImageName: ""), title: "These dates already have a title, select which ones to keep (this will delete the old titles and cannot be undone):")
                let overCells = overwrite.count == 0 ? [] : ( [overwriteCell] + overwrite.map { (tit) -> FormCell in
                    let key = tit.key
                    let val = tit.value
                    
                    return FormCell(type: .BoolInput(color: nil, subTitle: [ (key.optionalDay?.toString ?? ""), "Old title: " + val.original]), title: val.new) { (inp) in
                        if let b = inp as? Bool{
                            overwrite[key]?.overwrite = b
                        }
                    } get: { () -> Any in
                        return overwrite[key]?.overwrite ?? true
                    }
                })
                
                
                let newCell = FormCell(type: .StringTitle(systemImageName: ""), title: "These titles are new, select which to ignore:")
                let newCells = new.count == 0 ? [] : ([newCell] + new.map { (tit) -> FormCell in
                    let key = tit.key
                    let val = tit.value
                    
                    return FormCell(type: .BoolInput(color: nil, subTitle: [ (key.optionalDay?.toString ?? "")]), title: val.title) { (inp) in
                        if let b = inp as? Bool{
                            new[key]?.add = b
                        }
                    } get: { () -> Any in
                        return new[key]?.add ?? true
                    }
                })
                
                FormVC.top?.showForm({ () -> FormProperties in
                    let cells = new.count + overwrite.count == 0 ? [FormCell(type: .StringTitle(systemImageName: ""), title: "This file doesn't have any new titles to add.")] : (overCells + newCells)
                    return FormProperties(title: "File Titles", done: {
                        GetSetTitles.set(overwrite: overwrite, new: new)
                    }, cells: cells, button: new.count + overwrite.count == 0 ? .none : .init(label: "Cancel", showAlert: false))
                })
            }
            catch{
                
            }
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
                let share = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.up"), title: "Export To File", tap:  {
                    self.shareFile()
                })
                let save = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.down"), title: "Import From File", tap:  {
                    self.setFromFile()
                })
                return FormProperties(title: "Import And Export", cells: [share,save], button: .none)
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

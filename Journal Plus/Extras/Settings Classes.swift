//
//  Settings Classes.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 08/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
//import SwipeView
import WidgetKit

let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

let fullWeek = ["Sunday", "Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday"]

protocol Setting{
    associatedtype T
    static var value : T {set get}
    static var last : T? {get set}
    static var key : String {get}
    static var defaultValue : T {get}
    
    static func restoreValue()
    static var backup : T? {set get}
    
    static func updated(_ newValue : T)
    
    static func reload()
    
    static func set()
}


extension Setting{
    static func updated(_ newValue : T) {}
    static func restoreValue(){
        BackUp(key).restoreValue()
    }
    static func reload(){
        if let c = backup{
            last = c
        }else{
            last = defaultValue
        }
    }
    static var value : T{
        get{
            if let last_ = last{
                return last_
            }else{
                reload()
                return last ?? defaultValue
            }
        }
        set{
            last = newValue
            backup = newValue
            updated(newValue)
        }
    }
    
    static func set(){
        let arr = self.value
        self.value = arr
    }
}

protocol KeyedSetting : Setting{
}
extension KeyedSetting{
    static var backup : T?{
        set{
            if let v = newValue{
                BackUp(key).set(v)
            }else{
                BackUp(key).restoreValue()
            }
            
        }
        get{
            return BackUp(key).get()
        }
    }
}
protocol CodableSetting : Setting where T : Codable {
}
extension CodableSetting{
    static var backup : T?{
        set{
            if let v = newValue{
                BackUp(key).set(v)
            }else{
                BackUp(key).restoreValue()
            }
            
        }
        get{
            return BackUp(key).get()
        }
    }
}

class AppTintColor : KeyedSetting{
    
    static var last: UIColor? = nil
    
    static let key = "colorBackUpKey2"
    static let defaultValue = UIColor(named: "Green")!

}

class DateStyle : CodableSetting{
    
    static var last: DateFormatter.Style? = nil
    static let key = "dateWrittenTypeBackUpKey2"
    static let defaultValue = DateFormatter.Style.short
    static let styles : [DateFormatter.Style] = [.short,.medium,.long,.full]
}

class ExtendButton: KeyedSetting{
    static var last: Bool? = nil
    static let key = "expandButtonKey"
    static let defaultValue = false
}

class Capitalize: KeyedSetting{
    static var last: Bool? = nil
    static let key = "CapitalizeTitlesKey"
    static let defaultValue = true
}

class Indicator: KeyedSetting{
    static var last: Bool? = nil
    static let key = "expandedIndicatorKey"
    static let defaultValue = true
}

class WidgetStyle : KeyedSetting{
    static var last: Int? = nil
    static let key = "WidgetStyleBackupKey"
    static let defaultValue = 0
    // 0 - match app
    // 1 - match icon
}

class Icon{
    
    class Index : KeyedSetting{
        static var last: Int? = nil
        static let key = "IconIndexBackUpKey"
        static let defaultValue = 6
    }
    class Dark : KeyedSetting{
        static var last: Bool? = nil
        static let key = "IconDarknessBackUpKey"
        static let defaultValue = false
    }
    
    static func get (dark : Bool) -> Int{
        if dark == Dark.value{
            return Index.value
        }else{
            return -1
        }
    }
    
    static func isCurrent (at index : Int, dark : Bool) -> Bool{
        return Index.value == index && Dark.value == dark
    }
    
    static let names = ["Black","Dark Red","Red","Orange","Yellow","Cyan","Green","Blue","Purple","Dark Pink","Pink"]
}


let titles = Titles()
class Titles : CodableSetting{
    
    static var last: [Int:[Int:[Int:String]]]? = nil
    
    static let key = "titlesBackUpKey2"
    static let defaultValue : [Int:[Int:[Int:String]]] = [:]
    
    subscript (y : Int, m : Int, d : Int) -> String?{
        get{
            return Titles.value[y]?[m]?[d]?.title
        }
        set (title){
            if !Day(y, m, d).valid{
                return
            }
            
            if title == nil || title == ""{
                Titles.removeDay(y, m, d)
                return
            }
            
            if(Titles.value[y] == nil){
                Titles.value[y] = [:]
            }
            if(Titles.value[y]?[m] == nil){
                Titles.value[y]?[m] = [:]
            }
            
            if Titles.value[y]?[m]?[d] == nil{
                Titles.value[y]?[m]?[d] = title
            }else{
                Titles.value[y]?[m]?[d]?.title = title
            }
        }
    }
    
    subscript (y : Int, m : Int, d : Int, expanded : Bool) -> String?{
        get{
            return Titles.value[y]?[m]?[d]
        }
        set (title){
            if !Day(y, m, d).valid{
                return
            }
            if title == "" || title == nil{
                Titles.removeDay(d,m,y)
                return
            }
            
            if(Titles.value[y] == nil){
                Titles.value[y] = [:]
            }
            if(Titles.value[y]?[m] == nil){
                Titles.value[y]?[m] = [:]
            }
            Titles.value[y]?[m]?[d] = title
        }
    }
    
    subscript (day : Day) -> String?{
        get{
            return Titles()[day.y,day.m,day.d]
        }
        set (title){
            return Titles()[day.y,day.m,day.d] = title
        }
    }
    
    subscript (day : Day, expanded : Bool) -> String?{
        get{
            return Titles()[day.y,day.m,day.d,expanded]
        }
        set (title){
            return Titles()[day.y,day.m,day.d,expanded] = title
        }
    }
    
    static func removeDay (day : Day){
        let (y,m,d) = day.split
        removeDay(y,m,d)
    }
    static func removeDay (_ y : Int,_ m : Int,_ d : Int){
        Titles.value[y]?[m]?.removeValue(forKey: d)
        
        if(Titles.value[y]?[m]?.isEmpty ?? false){
            Titles.value[y]?.removeValue(forKey: m)
        }
        if(Titles.value[y]?.isEmpty ?? false){
            Titles.value.removeValue(forKey: y)
        }
        if Titles.value.isEmpty{
            Titles.restoreValue()
        }
        
    }
    
    static var fullArray : [(Day, String)]{
        var final : [(Day,String)] = []
        for (year, months) in Titles.value{
            for (month, days) in months{
                for (day, title) in days{
                    let day = Day(year,month,day)
                    if (day.valid){
                        final.append((day,title))
                    }
                }
            }
        }
        return final.sorted(by: {$0.0 > $1.0})
    }
    
    static var array : [(Day,String)] {
        return fullArray.map { (day,title) -> (Day,String) in
            return (day,title.title ?? "")
        }
    }
    
    static func checkDuplicates (title : String, completion : (([Day]) -> Void)? = nil) -> [Day]{
        let same = Titles.array.filter { (_, title_) -> Bool in
            return title_.lowercased() == title.lowercased()
            }.sorted(by: {$0.0 > $1.0}).map { (arg) -> Day in
                return arg.0
        }
        if same.count > 1{
            completion?(same)
        }
        return same
    }
    
    
    static func contains (_ day : Day) -> Bool{
        return titles[day] != nil
    }
    
    static var days : [Day]{
        return Titles.fullArray.map({ (day, _) -> (Day) in
            return day
        })
    }
    
    static var unaddedDays : [Day]{
        let datesAdded : [Day] = days.reversed()
        if datesAdded.isEmpty{
            return []
        }
        var final : [Day] = []
        for i in 0 ... datesAdded.count-1{
            let firstDay = datesAdded[i]
            let lastDay = i + 1 < datesAdded.count ? datesAdded[i+1] : Day()
            if firstDay.next != lastDay && firstDay != lastDay{
                var day = firstDay.next
                while(day != lastDay){
                    final.append(day)
                    day = day.next
                }
            }
        }
        return final.reversed()
    }
    
    static var duplicateDates : [(title :String, days: [Day])]{
        var dict : [String : [Day]] = [:]
        Titles.array.forEach {dict[$1.lowercased()] = (dict[$1.lowercased()] ?? []) + [$0]}
        let arr = dict.sorted(by: {$0.0 > $1.0 }).filter({$0.value.count > 1}).map { (arg) -> (title :String, days: [Day]) in
            return (title :arg.0, days: arg.1)
        }
        return arr
    }
    
    static func extented (day : Day) -> Bool{
        return titles[day, true]?.extended ?? false
    }
    
    static var years : [Int]{
        return value.map({ (arg) -> Int in
            return arg.0
        }).sorted(by: {$0 > $1})
    }
    static var monthsTuples : [(Int, String)]{
        var arr : [(Int, String)] = []
        for i in 1 ... 12{
            arr += [(i , months[i-1])]
        }
        return arr
    }
}

//old titles
func transferTitles(){
    if (TransferStatus.value == 0){
        let arr : [String:String] = getOldTitles()
        for (code, title) in arr{
            titles[code.day] = title
        }
        TransferStatus.value = 1
        oldBackUp("18111998").restoreEverything()
    }
}

func saveOnlySched(){
    let arr = Titles.value
    BackUp("18111998").restoreEverything()
    Titles.value = arr
}

class TransferStatus : KeyedSetting{
    
    static var last: Int? = nil
    
    static let titlesBackUpKey = "titlesBackUpKey"
    
    static let key = "transferStatus"
    static let defaultValue = 0
}

func getOldTitles() -> [String:String]{
    if let sched = oldBackUp(TransferStatus.titlesBackUpKey).anyObjectValue as? Data{
        do{
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(sched as Data) as! [String : String]
        }
        catch{
            return[:]
        }
        
    }else{
        return [:]
    }
}

class oldBackUp{
    var code = String()
    var defaults = UserDefaults.init(suiteName: "group.com.jacobhanna.journalGroup")!
    
    init (_ code:String){
        self.code = code
    }
    
    func printAll(){
        print(defaults.dictionaryRepresentation())
    }
    
    //Get any value
    var anyObjectValue : AnyObject?{
        if(self.isAvailable){
            return(defaults.value(forKey: code))! as AnyObject
        }else{
            return(AnyObject?(nil))
        }
    }
    
    var isAvailable : Bool{
        return(defaults.value(forKey: code) != nil)
    }
    
    func restoreEverything(){
        if(code == "18111998"){
            defaults.dictionaryRepresentation().keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        }
    }
    
}

//
//  Class Extensions.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 08/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit

extension String : ToString{
    var day : Day{
        return optionalDay!
    }
    
    var optionalDay : Day?{
        let dayDay = String(self.dropLast(4))
        var dayYear = self
        dayYear.removeFirst(dayYear.count-4)
        let formatter = DateFormatter()
        formatter.dateFormat = "D-yyyy"
        return formatter.date(from: "\(dayDay)-\(dayYear)")?.toDay
    }
    
    func search (str : String) -> Bool{
        return self.lowercased().contains(str.lowercased())
    }
    
    var toString : String{
        let split = self.split(separator: "\n")
        return split.count > 0 ? String(split[0]) : ""
    }
    
    var fullString : String{
        return self
    }
    
    var extended : Bool{
        let fullTitle = self.replacingOccurrences(of: "\n", with: "")
        return self != fullTitle
    }
    
    var title : String?{
        get{
            let sub = self.split(separator: "\n")
            if sub.count > 0{
                return String(sub[0])
            }else{
                return nil
            }
        }
        mutating set{
            var sub = self.split(separator: "\n").map { (ss) -> String in
                return String(ss)
            }
            if sub.count > 0{
                sub[0] = newValue ?? ""
                var new = ""
                sub.forEach { (str) in
                    new += str + "\n"
                }
                new.removeLast()
                self = new
            }else{
                self = newValue ?? ""
            }
        }
    }
}

extension Date : ToString{
    var minute : Int{
        return NSCalendar.current.component(.minute, from: self)
    }
    var hour : Int{
        return NSCalendar.current.component(.hour, from: self)
    }
    var day : Int{
        return NSCalendar.current.component(.day, from: self)
    }
    var month : Int{
        return NSCalendar.current.component(.month, from: self)
    }
    var year : Int{
        return NSCalendar.current.component(.year, from: self)
    }
    var weekday : Int{
        return NSCalendar.current.component(.weekday, from: self)
    }
    var code : String{
        let formatter = DateFormatter()
        formatter.dateFormat = "D"
        let day = formatter.string(from: self)
        formatter.dateFormat = "yyyy"
        return day + formatter.string(from: self)
    }
    
    var toDay : Day{
        return Day(self)
    }

    var toString : String{
        let formatter = DateFormatter()
        formatter.dateStyle = DateStyle.value
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

extension Array : ToString where Element: ToString {
    var toString: String {
        let extra = " , "
        var final : String = ""
        for i in self{
            final += i.toString
            final += extra
        }
        final.removeLast(extra.count)
        return final
    }
    
}
extension DateFormatter.Style : Codable{
    enum CodingKeys: String, CodingKey
    {
        case raw
    }
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rawValue, forKey: .raw)

    }
    public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = DateFormatter.Style(rawValue: try values.decode(UInt.self, forKey: .raw)) ?? DateFormatter.Style.short
    }
}


extension UITableViewCell{
    override open func awakeFromNib() {
        tintColorDidChange()
    }
    override open func tintColorDidChange() {
        let bgColorView = UIView()
        bgColorView.backgroundColor = self.tintColor.withAlphaComponent(0.2)
        self.selectedBackgroundView = bgColorView
    }
}

extension UISwitch{
    override open func awakeFromNib() {
        tintColorDidChange()
    }
    override open func tintColorDidChange() {
        self.onTintColor = Color.value
    }
}

class Day: Comparable, ToString, CustomStringConvertible, Codable{
    var description: String{
        return "\(y)/\(m)/\(d)"
    }
    
    
    static func < (lhs: Day, rhs: Day) -> Bool {
        return lhs.y == rhs.y ? (lhs.m == rhs.m ? lhs.d < rhs.d : lhs.m < rhs.m) : lhs.y < rhs.y
    }
    
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.y == rhs.y && lhs.m == rhs.m && lhs.d == rhs.d
    }
    
    var y = -1
    var m = -1
    var d = -1
    
    init(_ y : Int , _ m : Int , _ d : Int) {
        if (d <= Day.dayInMonth(y,m) && m >= 1 && m <= 12){
            self.y = y
            self.m = m
            self.d = d
        }
    }
    
    
    init (_ day : Day){
        self.y = day.y
        self.m = day.m
        self.d = day.d
    }
    
    init (_ date : Date = Date()){
        self.y = date.year
        self.m = date.month
        self.d = date.day
    }
    
    var valid : Bool{
        return y != -1
    }
    
    var toDate : Date{
        let components = DateComponents(year:y,month:m,day:d)
        return Calendar.current.date(from: components)!
    }
    
    var toString: String{
        return toDate.toString
    }
    
    var weekday : Int{
        return toDate.weekday
    }
    
    var enabled : Bool{
        return self <= Day()
    }
    
    var next : Day{
        let nextDay = Day(self)
        nextDay.d += 1
        if (nextDay.d > Day.dayInMonth(nextDay.y,nextDay.m)){
            nextDay.d = 1
            nextDay.m += 1
            if (nextDay.m > 12){
                nextDay.m = 1
                nextDay.y += 1
            }
        }
        return nextDay
    }
    
    var prev : Day{
        let nextDay = Day(self)
        nextDay.d -= 1
        if (nextDay.d < 1){
            nextDay.m -= 1
            if (nextDay.m < 1){
                nextDay.m = 12
                nextDay.y -= 1
            }
            nextDay.d = Day.dayInMonth(nextDay.y,nextDay.m)
        }
        return nextDay
    }
    
    var split : (Int,Int,Int){
        return (y,m,d)
    }
    
    static func leap (_ year : Int) -> Bool{
        return (year % 400 == 0 || ( year % 4 == 0 && year % 100 != 0))
    }
    static func dayInMonth (_ year : Int, _ month : Int) -> Int{
        if (month < 1 || month > 12){
            return 0
        }
        if (month == 2){
            return Day.leap(year) ? 29 : 28
        }
        return month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 ? 31 : 30
    }
    
    enum CodingKeys: String, CodingKey {
        case day
        case month
        case year
        case hour
        case minute
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(d, forKey: .day)
        try container.encode(m, forKey: .month)
        try container.encode(y, forKey: .year)
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        d = try values.decode(Int.self, forKey: .day)
        m = try values.decode(Int.self, forKey: .month)
        y = try values.decode(Int.self, forKey: .year)
    }
}

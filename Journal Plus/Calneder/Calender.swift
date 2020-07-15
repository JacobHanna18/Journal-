//
//  Calender.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 14/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import Foundation

class Calender{
    
    let dayTitles = ["Sun", "Mon", "Tue","Wed","Thu","Fri","Sat"]
    let miniDayTitles = ["S", "M", "T","W","T","F","S"]
    
    var month : Int = Day().m
    var year : Int = Day().y
    
    var start = 0
    var end = 0
    
    var days : [Day] = []
    
    let dayRows : Int = 6
    var dayCount : Int {
        return dayRows * 7
    }
    
    init() {
        days = [Day](repeating: Day(), count: dayCount)
        getDates()
    }
    
    func nextMonth(){
        month+=1
        if month == 13{
            month = 1
            year+=1
        }
        getDates()
    }
    
    func prevMonth(){
        month-=1
        if month == 0{
            month = 12
            year-=1
        }
        getDates()
    }
    
    func set (month : Int? = nil, year: Int? = nil){
        let m = month != nil ? month! : -1
        if(m>=1 && m<=12){
            self.month = month!
        }
        self.year = year != nil ? year! : self.year
        getDates()
    }
    
    func getDates(){
        var first = Day(year,month,1)
        var day = first
        start = day.weekday - 1
        days[day.weekday - 1] = day
        day = day.prev
        while(day.weekday != 7){
            days[day.weekday - 1] = day
            day = day.prev
        }
        var ended = false
        for i in first.weekday ..< dayCount{
            first = first.next
            days[i] = first
            if(first.m != month && !ended){
                end = i-1;
                ended = true
            }
        }
    }
    
}

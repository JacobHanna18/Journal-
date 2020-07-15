//
//  DayWidget.swift
//  DayWidget
//
//  Created by Jacob Hanna on 13/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    
    public typealias Entry = SimpleEntry
    
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> Void) {

        let calender = Calender()
        let highlights = calender.days.map { (day) -> Bool in
            return Titles.contains(day)
        }
        
        let entry = SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, textColor: Color.black, tint: Color("Green"), todayTitle: "Today's Title", prevTitle: "", calender: calender,highlights: highlights)

        completion(entry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
        Titles.reload()
        Icon.Dark.reload()
        Icon.Index.reload()
        
        let calender = Calender()
        let highlights = calender.days.map { (day) -> Bool in
            return Titles.contains(day)
        }
        let background = Icon.Dark.value ? Color.black : Color.white
        let text = Icon.Dark.value ? Color.white : Color.black
        let tint = Color(Icon.names[Icon.Index.value])
        
        let entry = SimpleEntry(date: Date(), day: Date().toDay, background: background, textColor: text, tint: tint, todayTitle: titles[Date().toDay], prevTitle: titles[Date().toDay.prev], calender: calender, highlights: highlights)
        let entries = [entry]
        let timeline = Timeline(entries: entries, policy: .after(Date().toDay.next.toDate.dayStart))
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let day: Day
    public let background : Color
    public let textColor : Color
    public let tint : Color
    public let todayTitle : String?
    public let prevTitle : String?
    public let calender : Calender
    public let highlights : [Bool]
}

struct PlaceholderView: View {
    
    
    
    private var entry : SimpleEntry
    
    init() {
        
        let calender = Calender()
        let highlights = calender.days.map { (day) -> Bool in
            return false
        }
        
        entry = SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, textColor: Color.black, tint: Color("Green"), todayTitle: "Today's Title", prevTitle: "", calender: Calender(), highlights: highlights)
    }
    
    var body: some View {
        
        DayWidgetEntryView(entry: entry)
    }
}

struct DayWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        
        ZStack{
            entry.background.edgesIgnoringSafeArea(.all)
            
            HStack{
                TodayView(entry: entry)
                CalenderView(calender: entry.calender,highlights: entry.highlights, tintColor: entry.tint)
                    .padding(.all, 8.0)
                    
            }
        }
        .foregroundColor(entry.textColor)
        .widgetURL(URL(string: "journalPlus://\(entry.date.code)")!)
        
    }
}

@main
struct DayWidget: Widget {
    private let kind: String = "DayWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(), placeholder: PlaceholderView()) { entry in
            DayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today View")
        .description("Check if you added a title today at a glance!")
        .supportedFamilies([.systemMedium])
    }
}

struct Widget_Previews: PreviewProvider {
    
    
    static var previews: some View {
        Group {
            
//            TodayView(entry: SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, forground: Color.black, todayTitle: "Today's Title", prevTitle: nil))
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//            DayWidgetEntryView(entry: SimpleEntry(date: Date(), day: Date().toDay, background: Color.blue, forground: Color.black, todayTitle: "Today's Title", prevTitle: ""))
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
        }
    }
}

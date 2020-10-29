//
//  DayWidget.swift
//  DayWidget
//
//  Created by Jacob Hanna on 13/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import WidgetKit
import SwiftUI

var todaysEntry : SimpleEntry{
    Titles.reload()
    Icon.Dark.reload()
    Icon.Index.reload()
    WidgetStyle.reload()
    AppTintColor.reload()
    
    let calender = Calender()
    let highlights = calender.days.map { (day) -> Bool in
        return Titles.contains(day)
    }
    let background : Color? = WidgetStyle.value == 0 ? nil : (Icon.Dark.value ? Color.black : Color.white)
    let text = WidgetStyle.value == 0 ? nil : Icon.Dark.value ? Color.white : Color.black
    let tint = WidgetStyle.value == 0 ? Color(AppTintColor.value) : Color(Icon.names[Icon.Index.value])
    
    return SimpleEntry(date: Date(),background: background, textColor: text, tint: tint, todayTitle: titles[Date().toDay], prevTitle: titles[Date().toDay.prev], calender: calender, highlights: highlights)
}

struct Provider: TimelineProvider {

    public typealias Entry = SimpleEntry
    
    public func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {

        let calender = Calender()
        let highlights = calender.days.map { (day) -> Bool in
            return Titles.contains(day)
        }
        
        let entry = SimpleEntry(date: Date(), background: Color.white, textColor: Color.black, tint: Color("Green"), todayTitle: "Today's Title", prevTitle: "", calender: calender,highlights: highlights)

        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
        
        let entries = [todaysEntry]
        let timeline = Timeline(entries: entries, policy: .after(Date().toDay.next.toDate.dayStart))
        
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return todaysEntry
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let background : Color?
    public let textColor : Color?
    public let tint : Color
    public let todayTitle : String?
    public let prevTitle : String?
    public let calender : Calender
    public let highlights : [Bool]
}


struct DayWidgetEntryView: View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor : Color{
        if let c = entry.background{
            return c
        }
        
        switch colorScheme {
        case .dark:
            return Color.black
        case .light:
            return Color.white
        @unknown default:
            return Color.black
        }
    }
    
    var textColor : Color{
        if let c = entry.textColor{
            return c
        }
        
        switch colorScheme {
        case .dark:
            return Color.white
        case .light:
            return Color.black
        @unknown default:
            return Color.white
        }
    }
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        ZStack{
            entry.background.edgesIgnoringSafeArea(.all)
            
            
            HStack{
                
                TodayView(entry: entry)
                
                if(family == WidgetFamily.systemMedium){
                    CalenderView(calender: entry.calender,highlights: entry.highlights, tintColor: entry.tint)
                        .padding(.all, 8.0)
                }
                
                    
            }
        
        }
        .foregroundColor(textColor)
        .widgetURL(URL(string: "journalPlus://\(entry.date.code)")!)
        
    }
}

@main
struct DayWidget: Widget {
    private let kind: String = "DayWidget"
    
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind ,provider: Provider()) { entry in
            DayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today View")
        .description("Check if you added a title today at a glance!")
        .supportedFamilies([.systemSmall,.systemMedium])
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

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

        let entry = SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, forground: Color.black, todayTitle: "Today's Title", prevTitle: "")

        completion(entry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
        WidgetBackgroundColor.reload()
        Titles.reload()
        WidgetTextColor.reload()
        let entry = SimpleEntry(date: Date(), day: Date().toDay, background: WidgetBackgroundColor.value.toColor, forground: WidgetTextColor.value.toColor, todayTitle: titles[Date().toDay], prevTitle: titles[Date().toDay.prev])
        let entries = [entry]
        let timeline = Timeline(entries: entries, policy: .never)
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let day: Day
    public let background : Color
    public let forground : Color
    public let todayTitle : String?
    public let prevTitle : String?
}

struct PlaceholderView: View {
    
    let entry = SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, forground: Color.black, todayTitle: "Today's Title", prevTitle: "")
    
    var body: some View {
        
        DayWidgetEntryView(entry: entry)
    }
}

struct TodayView : View{
    
    var entry: Provider.Entry
    
    var body: some View{
        VStack{
            
            HStack{
                VStack{
                    Text("\(fullWeek[entry.day.weekday-1])")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                    Text("\(entry.day.d)")
                        .font(.system(size: 40))
                        .multilineTextAlignment(.leading)
                        
                }
                .padding(.leading)
                
                if(entry.prevTitle == nil){
                    Spacer()
                    Text("You didn't add a title yesterday!")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            Text(entry.todayTitle ?? "You havn't added a title today.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct DayWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        
        ZStack {
            entry.background.edgesIgnoringSafeArea(.all)
            TodayView(entry: entry)
            
        }
        .foregroundColor(entry.forground)
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
        .supportedFamilies([.systemSmall])
    }
}

struct Widget_Previews: PreviewProvider {
    
    
    static var previews: some View {
        Group {
            
            TodayView(entry: SimpleEntry(date: Date(), day: Date().toDay, background: Color.white, forground: Color.black, todayTitle: "Today's Title", prevTitle: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            DayWidgetEntryView(entry: SimpleEntry(date: Date(), day: Date().toDay, background: Color.blue, forground: Color.black, todayTitle: "Today's Title", prevTitle: ""))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

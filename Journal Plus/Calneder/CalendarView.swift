//
//  CalendarView.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 30/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import SwiftUI

protocol CalenderDelegate : class {
    
    func dayChanged (day :Day, old : Day)
    func longHold (day :Day)
    
    func tapMonth()
    
    func highlighted (day : Day) -> Bool
    
    func indicator (day : Day) -> Bool
}

struct Zero: View {
    var body: some View {
        Spacer().frame(width:0, height:0)
    }
}

struct CalendarViewUI: View {
    
    var delegate : CalenderDelegate
    @ObservedObject var selectedDay = Day()
    @ObservedObject var calender : Calender = Calender()
    @State var re = true
    
    func set(_ d : Day){
        selectedDay.set(d)
        calender.set(month: d.m, year: d.y)
    }
    
    func reloadData(){
        let d = Day(selectedDay)
        selectedDay.set(selectedDay.prev)
        selectedDay.set(d)
    }
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    calender.prevMonth()
                }, label: {
                    Image(systemName: "arrow.left").font(.title)
                }).padding()
                Spacer()
                VStack {
                    Text(Calender.months[calender.month-1])
                    Text("\(calender.year.toString)").font(.system(size: 12))
                }.onTapGesture(perform: {
                    delegate.tapMonth()
                })
                Spacer()
                Button(action: {
                    calender.nextMonth()
                }, label: {
                    Image(systemName: "arrow.right").font(.title)
                }).padding()
            }
            Spacer()
            
            HStack {
                Zero()
                ForEach(0 ..< 7){ j in
                    ZStack {
                        Color.clear.aspectRatio(2 ,contentMode: .fit)
                        Text(Calender.dayTitles[j])
                    }
                    .padding(.all, 3.0)
                    Zero()
                }
                
            }
            
            Spacer()
            ForEach(0 ..< calender.dayRows){ i in
                HStack {
                    Zero()
                    ForEach(0 ..< 7){ j in
                        ZStack{
                            if selectedDay == calender[i,j]{
                                Color.accentColor
                            }else{
                                delegate.highlighted(day: calender[i,j]) ? Color.accentColor.opacity(0.4) : Color.clear
                            }
                            
                            if delegate.indicator(day: calender[i,j]){
                                HStack{
                                    Spacer()
                                    VStack{
                                        Spacer()
                                        Circle()
                                            .fill(Color(UIColor.label))
                                            .frame(width: 8, height: 8)
                                            .padding([.bottom, .trailing], 5.0)
                                            
                                    }
                                }
                            }
                            
                            Text(calender[i,j].d.toString).fontWeight(calender[i,j] == Day() ? .bold : .regular).opacity(calender[i,j].m == calender.month ? 1 : 0.3).foregroundColor(calender[i,j] == selectedDay ? Color(UIColor.systemBackground) : Color(UIColor.label))
                        }.onTapGesture {
                            let old = Day(selectedDay)
                            selectedDay.set(calender[i,j])
                            delegate.dayChanged(day: selectedDay, old: old)
                        }.onLongPressGesture {
                            delegate.longHold(day: calender[i,j])
                        }.cornerRadius(10).padding(.all, 3.0)
                        Zero()
                    }
                    
                }
                Zero()
            }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width < 0 {
                                calender.nextMonth()
                            }
                            
                            if value.translation.width > 0 {
                                calender.prevMonth()
                            }
                        }))
        }
    }
}

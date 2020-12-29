//
//  calenderView.swift
//  DoneTracker
//
//  Created by Jacob Hanna on 22/12/2020.
//

import SwiftUI

extension Binding {
    func onChange(_ completion: @escaping (Value) -> Void) -> Binding<Value> {
        .init(get:{ self.wrappedValue }, set:{ self.wrappedValue = $0; completion($0) })
    }
}

struct FinishCalenderView: View {

    @ObservedObject var calender : Calender
    @State var done : [[Bool]] = [[Bool]](repeating: [Bool](repeating: false, count: 7), count: 6)
    
    
    func updateDone(){
        done = Lists.selectedList.getDoneArray(calender: calender)
    }
    
    var tapMonth : (()->()) = {
        print("hello")
    }
    
    var color = Color(Lists.selectedList.color)
    var doneImage : String = Lists.selectedList.doneImageName
    var undoneImage : String = Lists.selectedList.undoneImageName
    
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
                    self.tapMonth()
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
                Spacer()
                ForEach(0 ..< 7){ j in
                    Text(Calender.dayTitles[j])
                    Spacer()
                }
                
            }
            
            Spacer()
            ForEach(0 ..< calender.dayRows){ i in
                HStack {
                    Spacer()
                    ForEach(0 ..< 7){ j in
                        VStack{
                            Text("\(calender[i,j].d)").fontWeight(calender[i,j] == Day() ? .semibold : .regular)
                            Button(action: {
                                done[i][j].toggle()
                                Lists.selectedList[calender[i,j]] = done[i][j]
                                Lists.set()
                            }, label: {
                                Image(systemName: done[i][j] ? doneImage : undoneImage).font(.title)
                            }).disabled(calender[i,j] > Day())
                        }.opacity(calender[i,j].m == calender.month ? 1 : 0.3)
                        Spacer()
                    }
                    
                }
                Spacer()
            }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width < 0 {
                                calender.nextMonth()
                            }
                            
                            if value.translation.width > 0 {
                                calender.prevMonth()
                            }
                        }))
        }.onChange(of: calender.month, perform: { value in
            updateDone()
        }).onChange(of: calender.year, perform: { value in
            updateDone()
        }).onChange(of: color, perform: { value in
            updateDone()
        }).onAppear(perform: {
            updateDone()
        }).accentColor(color)
    }
}

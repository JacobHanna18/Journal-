//
//  CalenderView.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 14/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import SwiftUI

struct TodayView : View{
    
    var entry: SimpleEntry
    
    var day : Day{
        return Day()
    }
    
    var body: some View{
        VStack{
            
            HStack{
                VStack{
                    Text("\(fullWeek[day.weekday-1])")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.leading)
                    Text("\(day.d)")
                        .font(.system(size: 33))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(entry.tint)
                        .padding(.trailing)
                        
                }
                .padding(.leading)
                Spacer()
                
                if(entry.prevTitle == nil){
                    Spacer()
                    Text("You didn't add a title yesterday!")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            Text(entry.todayTitle ?? "You haven't added a title today.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct CalenderView: View {
    
    let calender : Calender
    
    let highlights : [Bool]
    
    let tintColor : Color
    
    var body: some View{
        GeometryReader{geo in
            collectionView(geo.size.width / 7, geo.size.height / CGFloat(calender.dayRows + 1))
        }
        
    }
    
    func collectionView (_ w : CGFloat, _ h : CGFloat) -> some View{
        VStack(spacing: 0){
            HStack(spacing: 0){
                ForEach(0 ..< 7, id: \.self){ i in
                    dayCell(str: calender.miniDayTitles[i], highlighted: false, tintColor: tintColor, day: nil)
                }
            }
            
            ForEach(0 ..< calender.dayRows, id: \.self){ i in
                HStack(spacing: 0){
                    ForEach(0 ..< 7, id: \.self){ x in
                        let index = i * 7 + x
                        let day = calender.days[index]
                        dayCell(str: ("\(day.d)"), highlighted: highlights[index],tintColor: tintColor, day: day)
                    }
                }
            }

        }
    }

}


struct dayCell : View{
    
    let str : String
    let highlighted : Bool
    let tintColor : Color
    let day : Day?
    
    var body: some View {
        ZStack{
            if(highlighted){
                tintColor.opacity(0.4)
            }else{
                Color.clear
            }
            if let d = day{
                Text(str)
                    .font(.system(size: 10, weight: (d == Day() ? .bold : (d.m == Day().m ? .light : .ultraLight)), design: .default))
            }else{
                Text(str)
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundColor(tintColor)
            }
            
        }
        .cornerRadius(5)
        .padding(.all, 1)
    }
}

struct CalenderView_Previews: PreviewProvider {
    static var previews: some View {
        Text("ll")
    }
}

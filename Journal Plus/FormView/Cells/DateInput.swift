//
//  DateInput.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct DateInput: View {
    let cell : FormCell
    @State var inp: Date = Date()
    
    var components : DatePickerComponents{
        var time = false
        var date = true
        switch cell.type {
        case let .DateInput(showTime: x, showDate: y):
            time = x
            date = y
        default:
            break
        }
        
        if time && date{
            return [.date,.hourAndMinute]
        }else if time{
            return [.hourAndMinute]
        }else {
            return [.date]
        }
    }
    
    var body: some View {
        VStack{
            DatePicker(selection: $inp, displayedComponents: components) {
                CellTitleView(title: cell.title).onTapGesture(perform: {
                    cell.tap?()
                })
            }
        }.onAppear(perform: {
            inp = (cell.getT(Date.self) ?? Date())
        }).onChange(of: inp, perform: { value in
            cell.setT(inp)
        })
    }
}

var testDateInput : Date = Date()
struct DateInput_Previews: PreviewProvider {
    static var previews: some View {
        DateInTemp
    }
}

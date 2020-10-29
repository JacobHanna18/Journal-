//
//  LongtringInput.swift
//  FormView
//
//  Created by Jacob Hanna on 01/10/2020.
//

import SwiftUI

struct LongStringInput: View {
    let cell : FormCell
    @State var inp: String = ""
    var height : CGFloat{
        switch cell.type {
        case let .LongStringInput(height: h):
            return h
        default:
            return 100
        }
    }
    var body: some View {
        VStack{
            CellTitleView(title: cell.title).onTapGesture(perform: {
                cell.tap?()
            })
            ZStack{
                Color.accentColor.opacity(0.5)
                TextEditor(text: $inp).frame(minHeight: height, idealHeight: height, maxHeight: .infinity)
            }
           
        }.onAppear(perform: {
            inp = cell.getT(String.self) ?? ""
        }).onChange(of: inp, perform: { value in
            cell.setT(inp)
        })
    }
}

struct LongStringInput_Previews: PreviewProvider {
    static var previews: some View {
        LongStringInTemp
    }
}

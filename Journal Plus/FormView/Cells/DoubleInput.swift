//
//  DoubleInput.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct DoubleInput: View {
    let cell : FormCell
    @State var inp: String = "0.0"
    var body: some View {
        VStack{
            CellTitleView(title: cell.title).onTapGesture(perform: {
                cell.tap?()
            })
            TextField(cell.title ?? "DoubleIn Err", text: $inp, onCommit: {
                //UIApplication.shared.endEditing()
            }).keyboardType(.decimalPad).textFieldStyle(MyTextFieldStyle())
        }.onAppear(perform: {
            inp = (cell.getT(Double.self) ?? 0).toString
        }).onChange(of: inp, perform: { value in
            if let d = Double(inp){
                cell.setT(d)
            }
        })
    }
}

var testDoubleInput = 6.076
struct DoubleInput_Previews: PreviewProvider {
    static var previews: some View {
        DoubleInTemp
    }
}

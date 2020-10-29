//
//  ColorInput.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct ColorInput: View {
    let cell : FormCell
    @State var inp: Color = .red
    var body: some View {
        VStack{
            ColorPicker(selection: $inp, label: {
                CellTitleView(title: cell.title).onTapGesture(perform: {
                    cell.tap?()
                })
            })
        }.onAppear(perform: {
            inp = (cell.getT(Color.self) ?? Color.red)
        }).onChange(of: inp, perform: { value in
            cell.setT(inp)
        })
    }
}

var testColorInput : Color = .green
struct ColorInput_Previews: PreviewProvider {
    static var previews: some View {
        ColorInTemp
    }
}

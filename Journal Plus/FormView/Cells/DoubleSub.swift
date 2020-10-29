//
//  DoubleSub.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct DoubleSub: View {
    let cell : FormCell
    var body: some View {
        HStack{
            CellTitleView(title: cell.title)
            Text((cell.getT(Double.self) ?? 0).toString)
               
        }.onTapGesture(perform: {
            cell.tap?()
        })
    }
}

struct DoubleSub_Previews: PreviewProvider {
    static var previews: some View {
        DoubleSub(cell: FormCell(type: .DoubleSub, title: "Test Title", get: { () -> Any in
            return testDoubleInput
        }))
    }
}

//
//  IntSub.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct IntSub: View {
    let cell : FormCell
    var body: some View {
        HStack{
            CellTitleView(title: cell.title)
            Text((cell.getT(Int.self) ?? 0).toString)
        }.onTapGesture(perform: {
            cell.tap?()
        })
    }
}

struct IntSub_Previews: PreviewProvider {
    static var previews: some View {
        IntSub(cell: FormCell(type: .IntSub, title: "Test Title", get: { () -> Any in
            return testIntInput
        }))
    }
}

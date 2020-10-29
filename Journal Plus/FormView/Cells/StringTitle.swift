//
//  StringTitle.swift
//  FormView
//
//  Created by Jacob Hanna on 29/09/2020.
//

import SwiftUI

struct StringTitle: View {
    let cell : FormCell
    
    var systemImage : Image{
        switch cell.type {
        case let .StringTitle(systemImageName: name):
            return Image(systemName: name)
        default:
            return Image(systemName: "chevron.right")
        }
    }
    
    var body: some View {
        
        HStack{
            if cell.tap != nil{
                HStack {
                    Button(action: {cell.tap?()}, label: {
                        CellTitleView(title: cell.title)
                    })
                    Spacer()
                    Button(action: {cell.tap?()}, label: {
                        systemImage.padding(.leading, 10.0).font(.title2)
                    }).opacity(0.8)
                    
                }
            }else{
                CellTitleView(title: cell.title)
            }
        }
        
    }
}

struct StringTitle_Previews: PreviewProvider {
    static var previews: some View {
        StringTitle(cell: FormCell(type: .StringTitle(), title: "DemoTitle"))
    }
}

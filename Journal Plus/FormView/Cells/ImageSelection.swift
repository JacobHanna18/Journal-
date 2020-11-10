//
//  ImageSelection.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 10/11/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import SwiftUI

struct ImageSelection: View {
    let cell : FormCell
    
    @State var backgroundColor : [Color] = [Color.white]
    @State var ringColor : [Color] = [Color.black]
    @State var images : [[UIImage]] = []
    @State var height : CGFloat = 50
    @State var index : (Int,Int) = (-1,-1)
    @State var b : Bool = true
    
    func isEqual (col : Int,row: Int) -> Bool{
        return (index.0 == col) && (index.1 == row)
    }
    
    var body: some View {
        VStack{
            CellTitleView(title: cell.title).onTapGesture(perform: {
                cell.tap?()
            })
            
            VStack {
                ForEach((0..<images.count), id: \.self) {row in
                    HStack {
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach((0..<images[row].count), id: \.self) {col in
                                    
                                    Image(uiImage: images[row][col]).resizable()
                                        .scaledToFit()
                                        .cornerRadius(height/2)
                                        .padding(.all, 2)
                                        .background(isEqual(col: col, row: row) ? ringColor[row] : backgroundColor[row]).cornerRadius(height/2)
                                        .padding(.all, 2)
                                        .background(backgroundColor[row].cornerRadius(height/2)).onTapGesture(perform: {
                                            index = (col,row)
                                            b = !b
                                        })
                                    
                                }
                            }
                        }.frame(height: height)
                        Spacer()
                    }
                }
            }
            
        }.onAppear(perform: {
            index = (cell.getT((Int,Int).self) ?? (0,0))
            
            switch cell.type {
            case let .ImageSelection(images: img, background: b, ringColor: r):
                images = img
                backgroundColor = b
                ringColor = r
            default:
                break
            }
            
        }).onChange(of: b, perform: { value in
            cell.setT(index)
        })
    }
}

struct ImageSelection_Previews: PreviewProvider {
    
    static var previews: some View {
        Text("he")
    }
}

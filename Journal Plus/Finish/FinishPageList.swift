//
//  FinishPageList.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 04/01/2021.
//  Copyright © 2021 Jacob Hanna. All rights reserved.
//

import SwiftUI

struct FinishPageList: View {
    
    @ObservedObject var vc : FinishVC
    
    var selectionChanged : ((Int) -> ()) = {i in
        print(i)
    }
    
    var body: some View {
        TabView(selection: $vc.selectedList.onChange({ (i) in
            selectionChanged(i)
        })){
            ForEach(0 ..< (vc.labels.count), id: \.self) { i in
                HStack{
                    Text(vc.labels[i])
                        .font(.largeTitle).bold().foregroundColor(Color(Lists.value[i].listColor))
                        .padding()
                        .tag(i)
                    Spacer()
                }.onTapGesture {
                    vc.showForm({Lists.props(of: i)})
                }
                
            }
        }
        .id(vc.labels.count)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

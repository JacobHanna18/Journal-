//
//  CalenderView.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 14/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import SwiftUI

struct CalenderView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct dayCell : View{
    
    var day : Day
    var highlighted : Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CalenderView_Previews: PreviewProvider {
    static var previews: some View {
        dayCell(day: Date().toDay,highlighted: true)
    }
}

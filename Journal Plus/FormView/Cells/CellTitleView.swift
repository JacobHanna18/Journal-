//
//  CellTitleView.swift
//  FormView
//
//  Created by Jacob Hanna on 01/10/2020.
//

import SwiftUI

struct CellTitleView: View {
    let title : String?
    var body: some View {
        HStack {
            Text(title ?? "")
                .font(.title3)
            Spacer()
        }
    }
}

struct CellTitleView_Previews: PreviewProvider {
    static var previews: some View {
        CellTitleView(title: "Test")
    }
}

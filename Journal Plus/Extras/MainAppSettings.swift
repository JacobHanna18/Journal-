//
//  MainAppSettings.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 13/07/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView

extension AppTintColor {
    
    static func updated(_ newValue: UIColor) {
        mainWindow.tintColor = newValue
    }

}

extension Icon{

    static func setIcon (at index : Int, dark : Bool){
        let name = "\(names[index])\(dark ? "-DARK" : "")"
        UIApplication.shared.setAlternateIconName(name) { (err) in
            if let e = err{
                print(e.localizedDescription)
            }else{
                Index.value = index
                Dark.value = dark
                TopSwipeView.reload?()
            }
        }
    }

}

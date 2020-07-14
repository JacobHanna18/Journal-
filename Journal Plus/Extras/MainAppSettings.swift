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

class Icon{
    
    class Index : KeyedSetting{
        static var last: Int? = nil
        static let key = "IconIndexBackUpKey"
        static let defaultValue = 6
    }
    class Dark : KeyedSetting{
        static var last: Bool? = nil
        static let key = "IconDarknessBackUpKey"
        static let defaultValue = false
    }
    
    
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
    
    static func get (dark : Bool) -> Int{
        if dark == Dark.value{
            return Index.value
        }else{
            return -1
        }
    }
    
    static func isCurrent (at index : Int, dark : Bool) -> Bool{
        return Index.value == index && Dark.value == dark
    }
    
    static let names = ["Black","Dark Red","Red","Orange","Yellow","Cyan","Green","Blue","Purple","Dark Pink","Pink"]
}

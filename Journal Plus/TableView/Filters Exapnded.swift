//
//  FiltersVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 25/01/2019.
//  Copyright © 2019 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView

protocol FiltersDelegate {
    var filters : [(String, [Filter])] {get}
    var enabled : [(Int,Int)] {get set}
    
    var and : Bool {get set}
    var reverse : Bool {get set}
    
}



extension FiltersDelegate {
    func presentFiltersView (_ vc : UIViewController,  update : @escaping ( ([(Int,Int)])-> Void), set : @escaping ((Bool?,Bool?)-> Void)){
        
        let andOr = SelectionPoint("How to calculate", get: self.and ? 0 : 1,set: { (i) in
            if i == 0{
                set(true, nil)
            }else{
                set(false, nil)
            }
        }, labels: ["And", "Or"], defaultIndex: 0)
        
        let reverse = InputPoint<Bool>("Reverse", get: self.reverse, set: { (b) in
            set(nil, b)
        })
        
        vc.presentPointView(PointsList(points: { () -> [MainPoint] in
            var i = -1;
            let points = self.filters.reduce([]) { (arr, arg1) -> [MainPoint] in
                i += 1
                let section = i
                let (name, filters) = arg1
                let nPoint = DataPoint<String>(name, background: UIColor.secondarySystemBackground)
                var j = -1
                let filtersPoints = filters.map { (filter) -> MainPoint in
                    j += 1
                    let row = j
                    let isOn = self.enabled.contains(where: {$0 == section && $1 == row})
                    return InputPoint<Bool>(filter.name, get: isOn, set: { (newOn) in
                        if newOn{
                            update(self.enabled + [(section,row)])
                            //self.enabled.append((section, row))
                        }else{
                            
                            var arr = self.enabled
                            arr.removeAll(where: {$0 == section && $1 == row})
                            update(arr)
                        }
                    })
                }
                return arr + [nPoint] + filtersPoints
            }
            
            
            
            
            return [andOr, reverse] + points
        }, title: "Filters", delete: {
            update([])
        }, .clear))
    }
}

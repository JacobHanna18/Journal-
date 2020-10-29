//
//  FiltersVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 25/01/2019.
//  Copyright © 2019 Jacob Hanna. All rights reserved.
//

import UIKit

protocol FiltersDelegate {
    var filters : [(String, [Filter])] {get}
    var enabled : [(Int,Int)] {get set}
    
    var and : Bool {get set}
    var reverse : Bool {get set}
    
}



extension FiltersDelegate {
    func presentFiltersView (_ vc : UIViewController,  update : @escaping ( ([(Int,Int)])-> Void), set : @escaping ((Bool?,Bool?)-> Void)){
        
        let andOr = FormCell(type: .SingleSelection(labels: ["And", "Or"]), title: "How to calculate",divider: true) { (inp) in
            if let i = inp as? Int{
                if i == 0{
                    set(true, nil)
                }else{
                    set(false, nil)
                }
            }
        } get: { () -> Any in
            self.and ? 0 : 1
        }

        let reverse = FormCell(type: .BoolInput(), title: "Reverse", divider: true) { (inp) in
            if let b = inp as? Bool{
                set(nil, b)
            }
        } get: { () -> Any in
            self.reverse
        }

        var i = -1
        let points = self.filters.reduce([]) { (arr, arg1) -> [FormCell] in
            i += 1
            let section = i
            let (name, filters) = arg1
            let nPoint = FormCell(type: .StringTitle(), title: name)
            var j = -1
            let filtersPoints = filters.map { (filter) -> FormCell in
                j += 1
                let row = j
                let isOn = self.enabled.contains(where: {$0 == section && $1 == row})
                return FormCell(type: .BoolInput(), title: filter.name, divider: filters.count-1 == row) { (inp) in
                    if let newOn = inp as? Bool{
                        if newOn{
                            update(self.enabled + [(section,row)])
                            //self.enabled.append((section, row))
                        }else{
                            
                            var arr = self.enabled
                            arr.removeAll(where: {$0 == section && $1 == row})
                            update(arr)
                        }
                    }
                } get: { () -> Any in
                    isOn
                }
            }
            return arr + [nPoint] + filtersPoints
        }
        
        vc.showForm { () -> FormProperties in
            FormProperties(title: "Filters", delete: {
                update([])
            }, cells: [andOr,reverse] + points, button: .init(label: "Clear", showAlert: false))
        }

        
        /*let andOr = SelectionPoint("How to calculate", get: self.and ? 0 : 1,set: { (i) in
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
        }, .clear)) */
    }
}

//
//  unaddedVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 13/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView

class unaddedVC: UITableViewController, ListTableViewDelegate, Reloadable {
    
    var array: [(ToString, ToString)]{
        return Titles.unaddedDays.map({ (date) -> (ToString,ToString) in
            return (date as ToString, "")
        })
    }
    
    var filters: [(String, [Filter])]{
        let arr = Titles.unaddedDays
        return [("General", [
            Filter("This Year", { (index) -> Bool in
                return arr[index].y == Day().y
            })
            ]),
                ("Years", Titles.years.map({ (year) -> Filter in
                    return Filter("\(year)", { (index) -> Bool in
                        return arr[index].y == year
                    })
                })),
                ("Months", (0...11).map({ (month) -> Filter in
                    return Filter(months[month], { (index) -> Bool in
                        return arr[index].m == month + 1
                    })
                }))
        ]
    }
    
    @IBAction func filter(_ sender: Any) {
        (tableView as! ListTableView).presentFilters()
    }
    
    func selectedIndex(index: Int) {
        selectDate(day: Titles.unaddedDays[index])
    }
    
    func accessoryType(index: Int) -> UITableViewCell.AccessoryType {
        return .detailButton
    }
    
    func selectedAccessory(index: Int) {
        self.presentExpandedView(Titles.unaddedDays[index])
    }
    
    var vc: UIViewController{
        return self
    }
    
    override func viewDidLoad() {
        (tableView as! ListTableView).set(delegate: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
}

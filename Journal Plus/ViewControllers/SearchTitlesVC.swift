//
//  searchTitlesVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 06/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit

class SearchTitlesVC: UITableViewController, ListTableViewDelegate, Presenting {
    
    var array_ : [(ToString, ToString)] = []
    var array: [(ToString, ToString)]{
        return array_
    }
    
    @IBAction func filter(_ sender: Any) {
        (tableView as! ListTableView).presentFilters()
    }
    var filters: [(String, [Filter])]{
        let arr = Titles.fullArray
        return [("General", [
            Filter("Extended", { (index) -> Bool in
                return arr[index].1.extended
            }),
            Filter("Not Extended", { (index) -> Bool in
                return !arr[index].1.extended
            }),
            Filter("This Year", { (index) -> Bool in
                return arr[index].0.y == Day().y
            })
            ]),
                ("Years", Titles.years.map({ (year) -> Filter in
                    return Filter("\(year)", { (index) -> Bool in
                        return arr[index].0.y == year
                    })
                })),
                ("Months", (0...11).map({ (month) -> Filter in
                    return Filter(months[month], { (index) -> Bool in
                        return arr[index].0.m == month + 1
                    })
                }))
        ]
    }
    
    func selectedIndex(index: Int) {
        selectDate(day: Titles.array[index].0)
    }
    
    func accessoryType(index: Int) -> UITableViewCell.AccessoryType {
        return .detailButton
    }
    
    func selectedAccessory(index: Int) {
        self.presentExpandedView(Titles.array[index].0)
    }
    
    
    var vc: UIViewController{
        return self
    }
    
    func reload() {
        
        array_ = Titles.fullArray.map({ (day, title) -> (ToString, ToString) in
            return (title as ToString, day as ToString)
        })
        
        tableView.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        (tableView as! ListTableView).set(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
}

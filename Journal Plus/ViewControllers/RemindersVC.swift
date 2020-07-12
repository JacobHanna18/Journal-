//
//  searchTitlesVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 06/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView

class RemindersVC: UITableViewController, ListTableViewDelegate, Reloadable {
    
    var array: [(ToString, ToString)]{
        return Reminders.array.map({ (r) -> (ToString,ToString) in
            return r.toString
        })
    }
    
    func selectedIndex(index: Int) {
        self.presentReminderView(Reminders.array[index])
    }
    
    var vc: UIViewController{
        return self
    }
    
    func reload() {
        tableView.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        (tableView as! ListTableView).set(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

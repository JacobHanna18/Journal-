//
//  duplicatesVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 16/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
import SwipeView


class duplicatesVC: UITableViewController, ListTableViewDelegate, Reloadable {
    func reload() {
        tableView.reloadData()
    }
    
    var array: [(ToString, ToString)]{
        return Titles.duplicateDates.map({($0.0 as ToString, $0.1 as ToString)})
    }
    
    func selectedIndex(index: Int) {
        let duplicates = Titles.duplicateDates[index]
        self.presentDuplicate(duplicates.days, title: duplicates.title)
        /*let alert = UIAlertController(title: "Select date to change title", message: nil, preferredStyle: .alert)
        for i in Titles.duplicateDates[index].1{
            alert.addAction(UIAlertAction(title: i.toString, style: .default, handler: { (action) in
                selectDate(day: i)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)*/
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
    
}

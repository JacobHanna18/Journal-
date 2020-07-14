//
//  ListTableView.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 13/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit

class Filter{
    var name : String
    var filter : (Int) -> Bool
    init(_ name : String , _ filter : @escaping (Int) -> Bool) {
        self.name = name
        self.filter = filter
    }
}



protocol ListTableViewDelegate {
    var array : [(ToString, ToString)] {get}
    func selectedIndex (index : Int)
    var vc : UIViewController {get}
    
    func selectedAccessory (index : Int)
    func accessoryType (index : Int) -> UITableViewCell.AccessoryType
    
    var filters : [(String, [Filter])] {get}
    
}

extension ListTableViewDelegate{
    var indexedArray : [(ToString , ToString , Int)]{
        var i = -1
        return array.map({ (title, subtitle) -> (ToString,ToString,Int) in
            i += 1
            return (title,subtitle,i)
        })
    }
    
    var filters : [(String, [Filter])]{
        return []
    }
    func selectedAccessory (index : Int){
        
    }
    func accessoryType (index : Int) -> UITableViewCell.AccessoryType{
        return .none
    }
}


class ListTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersDelegate {
    var enabled: [(Int, Int)] = []
    
    
    var filters: [(String, [Filter])] {
        return ListDelegate?.filters ?? []
    }
    
    
    
    
    var and : Bool = true
    var reverse = false
    
    
    
    var ListDelegate : ListTableViewDelegate?
    let cellId = "listCellId"
    
    var searchResults : [(ToString,ToString,Int)] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var array : [(ToString,ToString, Int)] = []

    override func awakeFromNib() {
        delegate = self
        dataSource = self
        register(UINib(nibName: "ListCell", bundle: nil) , forCellReuseIdentifier: cellId)

    }
    
    func set( delegate : ListTableViewDelegate){
        
        ListDelegate = delegate

        searchResults = array
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Titles"
        searchController.searchBar.delegate = self
        ListDelegate?.vc.navigationItem.searchController = searchController
        ListDelegate?.vc.navigationItem.hidesSearchBarWhenScrolling = false
        ListDelegate?.vc.definesPresentationContext = true
        array = ListDelegate?.indexedArray ?? []
        reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let (title, subtitle, _) = searchResults[indexPath.row]
        if title.toString != ""{
            cell.textLabel?.text = title.toString
        }else{
            cell.textLabel?.text = nil
        }
        if subtitle.toString != ""{
            cell.detailTextLabel?.text = subtitle.toString
        }else{
            cell.detailTextLabel?.text = nil
        }
        
        cell.accessoryType = ListDelegate?.accessoryType(index: searchResults[indexPath.row].2) ?? .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ListDelegate?.selectedIndex(index: searchResults[indexPath.row].2)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        dismissSearchController()
        ListDelegate?.selectedAccessory(index: searchResults[indexPath.row].2)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(searchText)
        reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissSearchController()
    }
    
    override func reloadData() {
        let filters = ListDelegate?.filters
        array = (ListDelegate?.indexedArray ?? []).filter({ (_,_,index) -> Bool in
            return enabled.reduce(and, { (res, arg1) -> Bool in
                let (i, j) = arg1
                if and{
                    return res && (filters?[i].1[j].filter(index) ?? true)
                }else{
                    return res || (filters?[i].1[j].filter(index) ?? true)
                }
                
            })
        })
        if reverse{
            array.reverse()
        }
        updateSearchResults(searchController.searchBar.text ?? "")
        super.reloadData()
    }
    
    func updateSearchResults (_ searchText : String){
        if searchText == ""{
            searchResults = array
        }else{
            searchResults = array.filter({ (title, subtitle , _) -> Bool in
                return title.fullString.search(str: searchText) || subtitle.fullString.search(str: searchText)
            })
        }
    }
    
    func dismissSearchController (){
        searchController.dismiss(animated: true, completion: nil)
        searchResults = array
        reloadData()
    }
    
    func presentFilters (){
        self.presentFiltersView((ListDelegate as? UIViewController)!, update: { (arr) in 
            self.enabled = arr
        }, set: ({(o , r) in
            self.and = o ?? self.and
            self.reverse = r ?? self.reverse
        }))
    }
}

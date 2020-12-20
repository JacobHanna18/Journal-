//
//  Share File Functions.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 21/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit


class GetSetTitles {
    static var fileExtension = "journaltitles"
    static func get() throws -> String{
        var dic : [String : String] = [:]
        Titles.fullArray.forEach { (day, title) in
            dic[day.toDate.code] = title
        }
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
            return jsonString ?? ""
        }
        catch{
            throw error
            
        }
    }
    
    static func set(str : String) throws -> (override :[String : (original:String, new:String, overwrite:Bool)], add :[String : (title:String, add:Bool)]){

        var dic : [String : String] = [:]
        if let data = str.data(using: String.Encoding.utf8) {
            do {
                dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] ?? [:]
            } catch let error as NSError {
                throw error
            }
        }
        
        var overwrite :[String : (original:String, new:String, overwrite:Bool)] = [:]
        var new :[String : (title:String, add:Bool)] = [:]
        
        for (day, title) in dic{
            if let day_ = day.optionalDay{
                if let tit = titles[day_,true]{
                    if tit != title{
                        overwrite[day] = (tit,title,false)
                    }
                }else{
                    new[day] = (title, true)
                }
            }
        }
        
        return (overwrite, new)
    }
    
    static func set (overwrite :[String : (original:String, new:String, overwrite:Bool)], new :[String : (title:String, add:Bool)]){
        
        for (day, data) in overwrite{
            if let day_ = day.optionalDay{
                if data.overwrite{
                    titles[day_,true] = data.new
                }
            }
        }
        
        for (day, data) in new{
            if let day_ = day.optionalDay{
                if data.add{
                    titles[day_,true] = data.title
                }
            }
        }
    }
    
    static func formViewFromFileString(str : String) -> FormProperties?{
        do {
            var (overwrite, new) = try GetSetTitles.set(str: str)
        
            let overwriteCell = FormCell(type: .StringTitle(systemImageName: ""), title: "These dates already have a title, select which ones to keep (this will delete the old titles and cannot be undone):")
            let overCells = overwrite.count == 0 ? [] : ( [overwriteCell] + overwrite.map { (tit) -> FormCell in
                let key = tit.key
                let val = tit.value
                
                return FormCell(type: .BoolInput(color: nil, subTitle: [ (key.optionalDay?.toString ?? ""), "Old title: " + val.original]), title: val.new) { (inp) in
                    if let b = inp as? Bool{
                        overwrite[key]?.overwrite = b
                    }
                } get: { () -> Any in
                    return overwrite[key]?.overwrite ?? true
                }
            })
            
            
            let newCell = FormCell(type: .StringTitle(systemImageName: ""), title: "These titles are new, select which to ignore:")
            let newCells = new.count == 0 ? [] : ([newCell] + new.map { (tit) -> FormCell in
                let key = tit.key
                let val = tit.value
                
                return FormCell(type: .BoolInput(color: nil, subTitle: [ (key.optionalDay?.toString ?? "")]), title: val.title) { (inp) in
                    if let b = inp as? Bool{
                        new[key]?.add = b
                    }
                } get: { () -> Any in
                    return new[key]?.add ?? true
                }
            })
            
            
            let cells = new.count + overwrite.count == 0 ? [FormCell(type: .StringTitle(systemImageName: ""), title: "This file doesn't have any new titles to add.")] : (overCells + newCells)
            return FormProperties(title: "File Titles", done: {
                    GetSetTitles.set(overwrite: overwrite, new: new)
                }, cells: cells, button: new.count + overwrite.count == 0 ? .none : .init(label: "Cancel", showAlert: false), listView: true)
        } catch {
            return nil
        }
    }
}

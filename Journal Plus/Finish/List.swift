//
//  List.swift
//  DoneTracker
//
//  Created by Jacob Hanna on 22/12/2020.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class Lists: CodableSetting{
    static var last: [doneList]? = nil
    static let key = "finishListKey"
    static let defaultValue: [doneList] = []
    
    static var selectedIndex : Int{
        get{
            if SelectedIndexSaved.value >= Lists.value.count{
                return 0
            }
            return SelectedIndexSaved.value
        }
        set{
            SelectedIndexSaved.value = newValue
        }
    }
    
    static var TabBarSelectedImageName : String{
        return selectedList.doneImageName
    }
    
    static var TabBarImageName : String{
        return selectedList.undoneImageName
    }
    
    class SelectedIndexSaved: CodableSetting {
        static var last: Int? = nil
        static let key = "selectedFinishList"
        static let defaultValue = 0
    }
    
    static var selectedList : doneList{
        get{
            if Lists.value.count == 0{
                Lists.newList()
            }
            return Lists.value[Lists.selectedIndex]
        }
        set{
            Lists.value[Lists.selectedIndex] = newValue
            Lists.set()
        }
    }
    
    static func newList (_ list : doneList = doneList()){
        Lists.value.append(list)
        Lists.set()
    }
    
    static var props : FormProperties{
        let newList = FormCell(type: .StringTitle(systemImageName: "calendar.badge.plus"), title: "Create New List", tap:  {
            Lists.newList()
            FormVC.top?.showForm({Lists.props(of: Lists.value.count - 1)})
        })
        
        let fromFile = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.down"), title: "New From File", tap:  {
            let selector = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: doneList.fileExtension)!], asCopy: true)
            selector.delegate = FinishVC.main
            FormVC.top?.present(selector, animated: true, completion: nil)
        })
        
        let selectList = FormCell(type: .StringTitle(), title: "Select list to show")
        
        var i = -1
        let listCells = Lists.value.map({ (l) -> FormCell in
            i += 1
            let j = i
            return FormCell(type: .StringTitle(systemImageName: i == Lists.selectedIndex ? "chevron.right.square.fill" : "chevron.right.square", extraButton: (imageName: "pencil.circle", tap: {
                FormVC.top?.showForm({Lists.props(of: j)})
                FormVC.top?.view.tintColor = l.listColor
            }), color: l.listColor), title: l.name, tap: {
                Lists.selectedIndex = j
                FormVC.top?.dismiss(animated: true, completion: nil)
            })
        })
        
        return FormProperties(title: "Lists", cells: [newList, fromFile, selectList] + listCells, button: .none)
    }
    
    static func props (of index : Int) -> FormProperties{
        let name = FormCell(type: .StringInput, title: "Name") { (inp) in
            if let s = inp as? String{
                Lists.value[index].name = s
                Lists.set()
            }
        } get: { () -> Any in
            return Lists.value[index].name
        }
        
        let matchApp = FormCell(type: .BoolInput(), title: "Match Color To App") { (inp) in
            if let b = inp as? Bool{
                Lists.value[index].colorMatchApp = b
                FormVC.top?.view.tintColor =  Lists.value[index].listColor
                
                
                Lists.set()
            }
        } get: { () -> Any in
            return Lists.value[index].colorMatchApp
        }
        
        let color = FormCell(type: .ColorInput, title: "Color") { (inp) in
            if let c = inp as? Color{
                FormVC.top?.view.tintColor = UIColor(c)
                Lists.value[index].color = UIColor(c)
                Lists.set()
            }
        } get: { () -> Any in
            return Color(Lists.value[index].color)
        }
        
        
        let doneImageName = FormCell(type: .MatrixSelection(columns: 10, values: Lists.images), title: "Done Image") { (inp) in
            if let i = inp as? Int{
                Lists.value[index].doneImageName = Lists.imageNames[i]
                Lists.set()
            }
        } get: { () -> Any in
            return Lists.imageNames.firstIndex(of: Lists.value[index].doneImageName) ?? -1
        }

        let undoneImageName = FormCell(type: .MatrixSelection(columns: 10, values: Lists.images), title: "Undone Image") { (inp) in
            if let i = inp as? Int{
                Lists.value[index].undoneImageName = Lists.imageNames[i]
                Lists.set()
            }
        } get: { () -> Any in
            return Lists.imageNames.firstIndex(of: Lists.value[index].undoneImageName) ?? -1
        }
        
        let export = FormCell(type: .StringTitle(systemImageName: "square.and.arrow.up"), title: "Export done list", tap: {
            let str = Lists.value[index].toString
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let filename = (paths[0] as NSString).appendingPathComponent("\(Lists.value[index].name).\(doneList.fileExtension)")

                do {
                    try str.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)

                    let fileURL = NSURL(fileURLWithPath: filename)

                    let objectsToShare = [fileURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    FormVC.top?.present(activityVC, animated: true, completion: nil)

                } catch {
                    print("cannot write file")
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
        })

        
        return FormProperties(title: "List", delete:{
            if Lists.selectedIndex == index{
                let alert = UIAlertController(title: "This list is selected, please select another list before deleting.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                FormVC.top?.present(alert, animated: true, completion: nil)
            }else{
                Lists.value.remove(at: index)
                Lists.set()
                if Lists.selectedIndex > index{
                    Lists.selectedIndex -= 1
                }
            }
        }, cells: [name,matchApp, color,doneImageName,undoneImageName, export], button: .delete)


    }
    
    static func newFrom (json str : String){
        
        if let jsonData = str.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            
            do {
                let list = try decoder.decode(doneList.self, from: jsonData)
                Lists.newList(list)
            } catch {
                print(error.localizedDescription)
                
            }
        }
    }
    
}


class doneList : Codable{
    var name : String
    var days : [Int:[Int:[Int:Bool]]]
    var color : UIColor
    var colorMatchApp : Bool
    var doneImageName : String
    var undoneImageName : String
    
    var listColor : UIColor{
        return colorMatchApp ? AppTintColor.value : color
    }
    
    static let fileExtension = "JournalDoneList"
    
    init() {
        name = "New List"
        days = [:]
        color = AppTintColor.value
        doneImageName = "checkmark.circle"
        undoneImageName = "circle"
        colorMatchApp = true
    }
    
    subscript(day : Day) -> Bool{
        get{
            if days[day.y] != nil{
                if days[day.y]?[day.m] != nil{
                    return days[day.y]?[day.m]?[day.d] ?? false
                }
            }
            return false
        }
        set{
            if newValue{
                addDay(day)
            }else{
                removeDay(day)
            }
            Lists.set()
        }
        
    }
    
    func getDoneArray(calender : Calender) -> [[Bool]]{
        var done : [[Bool]] = [[Bool]](repeating: [Bool](repeating: false, count: 7), count: 6)
        for i in 0 ..< 6{
            for j in 0 ..< 7{
                done[i][j] = Lists.selectedList[calender[i,j]]
            }
        }
        return done
    }
    
    func getCountOf(year : Int, month: Int) -> (Int, Int){
        var yearCount = 0
        var monthCount = 0
        if let months = days[year]{
            for (m,days) in months{
                for (_,d) in days{
                    if m == month{
                        monthCount += (d ? 1 : 0)
                    }
                    yearCount += (d ? 1 : 0)
                }
            }
        }
        return (yearCount, monthCount)
    }
    func addDay(_ day : Day){
        
        if days[day.y] == nil{
            days[day.y] = [:]
        }
        if days[day.y]?[day.m] == nil{
            days[day.y]?[day.m] = [:]
        }
        days[day.y]?[day.m]?[day.d] = true
    }
    
    func removeDay(_ day: Day){
        if days[day.y] != nil{
            if days[day.y]?[day.m] != nil{
                days[day.y]?[day.m]?.removeValue(forKey: day.d)
            }
        }
        
    }
    
    var toString : String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(self)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case days
        case doneImageName
        case undoneImageName
        case colorMatchApp
        
        case r,g,b,a
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(days, forKey: .days)
        try container.encode(doneImageName, forKey: .doneImageName)
        try container.encode(undoneImageName, forKey: .undoneImageName)
        try container.encode(colorMatchApp, forKey: .colorMatchApp)
        let (r,g,b,a) = color.rgba
        try container.encode(r, forKey: .r)
        try container.encode(g, forKey: .g)
        try container.encode(b, forKey: .b)
        try container.encode(a, forKey: .a)
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        days = try values.decode([Int:[Int:[Int:Bool]]].self, forKey: .days)
        doneImageName = try values.decode(String.self, forKey: .doneImageName)
        undoneImageName = try values.decode(String.self, forKey: .undoneImageName)
        
        do{
            colorMatchApp = try values.decode(Bool.self, forKey: .colorMatchApp)
        }catch{
            colorMatchApp = false
        }
        
        
        let r = try values.decode(CGFloat.self, forKey: .r)
        let g = try values.decode(CGFloat.self, forKey: .g)
        let b = try values.decode(CGFloat.self, forKey: .b)
        let a = try values.decode(CGFloat.self, forKey: .a)
        color = UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


extension UIColor{
    
    var rgba : (CGFloat,CGFloat,CGFloat,CGFloat) {
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            
            getRed(&r, green: &g, blue: &b, alpha: &a)
            
            return (r,g,b,a)
        }
}

extension Lists{
    static let imageNames = [
        "circle",
        "checkmark.circle",
        "checkmark.circle.fill",
        "pencil.circle",
        "pencil.circle.fill",
        "trash.circle",
        "trash.circle.fill",
        "folder.circle",
        "folder.circle.fill",
        "doc.circle",
        "doc.circle.fill",
        "calendar.circle",
        "calendar.circle.fill",
        "arrowshape.turn.up.left.circle",
        "arrowshape.turn.up.left.circle.fill",
        "arrowshape.turn.up.right.circle",
        "arrowshape.turn.up.right.circle.fill",
        "book.circle",
        "book.circle.fill",
        "paperclip.circle",
        "paperclip.circle.fill",
        "link.circle",
        "link.circle.fill",
        "pencil.tip.crop.circle",
        "person.circle",
        "person.circle.fill",
        "person.crop.circle",
        "person.crop.circle.fill",
        "circle.bottomthird.split",
        "moon.circle",
        "moon.circle.fill",
        "play.circle",
        "play.circle.fill",
        "pause.circle",
        "pause.circle.fill",
        "stop.circle",
        "stop.circle.fill",
        "magnifyingglass.circle",
        "magnifyingglass.circle.fill",
        "mic.circle",
        "mic.circle.fill",
        "heart.circle",
        "heart.circle.fill",
        "heart.slash.circle",
        "heart.slash.circle.fill",
        "star.circle",
        "star.circle.fill",
        "flag.circle",
        "flag.circle.fill",
        "location.circle",
        "location.circle.fill",
        "bell.circle",
        "bell.circle.fill",
        "tag.circle",
        "tag.circle.fill",
        "bolt.circle",
        "bolt.circle.fill",
        "ant.circle",
        "ant.circle.fill",
        "camera.circle",
        "camera.circle.fill",
        "phone.circle",
        "phone.circle.fill",
        "phone.down.circle",
        "phone.down.circle.fill",
        "envelope.circle",
        "envelope.circle.fill",
        "ellipsis.circle",
        "ellipsis.circle.fill",
        "lock.circle",
        "lock.circle.fill",
        "pin.circle",
        "pin.circle.fill",
        "mappin.circle",
        "mappin.circle.fill",
        "tv.circle",
        "tv.circle.fill",
        "viewfinder.circle",
        "viewfinder.circle.fill",
        "waveform.circle",
        "waveform.circle.fill",
        "purchased.circle",
        "purchased.circle.fill",
        "bolt.horizontal.circle",
        "bolt.horizontal.circle.fill",
        "grid.circle",
        "grid.circle.fill",
        "line.horizontal.3.decrease.circle",
        "line.horizontal.3.decrease.circle.fill",
        "f.cursive.circle",
        "f.cursive.circle.fill",
        "info.circle",
        "info.circle.fill",
        "questionmark.circle",
        "questionmark.circle.fill",
        "exclamationmark.circle",
        "exclamationmark.circle.fill",
        "plus.circle",
        "plus.circle.fill",
        "minus.circle",
        "minus.circle.fill",
        "plusminus.circle",
        "plusminus.circle.fill",
        "multiply.circle",
        "multiply.circle.fill",
        "divide.circle",
        "divide.circle.fill",
        "equal.circle",
        "equal.circle.fill",
        "lessthan.circle",
        "lessthan.circle.fill",
        "greaterthan.circle",
        "greaterthan.circle.fill",
        "number.circle",
        "number.circle.fill",
        "xmark.circle",
        "xmark.circle.fill",
        "chevron.up.circle",
        "chevron.up.circle.fill",
        "chevron.down.circle",
        "chevron.down.circle.fill",
        "chevron.left.circle",
        "chevron.left.circle.fill",
        "chevron.right.circle",
        "chevron.right.circle.fill",
        "arrow.up.circle",
        "arrow.up.circle.fill",
        "arrow.down.circle",
        "arrow.down.circle.fill",
        "arrow.left.circle",
        "arrow.left.circle.fill",
        "arrow.right.circle",
        "arrow.right.circle.fill",
        "arrow.up.left.circle",
        "arrow.up.left.circle.fill",
        "arrow.up.right.circle",
        "arrow.up.right.circle.fill",
        "arrow.down.left.circle",
        "arrow.down.left.circle.fill",
        "arrow.down.right.circle",
        "arrow.down.right.circle.fill",
        "arrow.up.arrow.down.circle",
        "arrow.up.arrow.down.circle.fill",
        "arrow.right.arrow.left.circle",
        "arrow.right.arrow.left.circle.fill",
        "arrow.uturn.up.circle",
        "arrow.uturn.up.circle.fill",
        "arrow.uturn.down.circle",
        "arrow.uturn.down.circle.fill",
        "arrow.uturn.left.circle",
        "arrow.uturn.left.circle.fill",
        "arrow.uturn.right.circle",
        "arrow.uturn.right.circle.fill",
        "arrow.up.and.down.circle",
        "arrow.up.and.down.circle.fill",
        "arrow.left.and.right.circle",
        "arrow.left.and.right.circle.fill",
        "arrow.clockwise.circle",
        "arrow.clockwise.circle.fill",
        "arrow.counterclockwise.circle",
        "arrow.counterclockwise.circle.fill",
        "arrow.2.circlepath.circle",
        "arrow.2.circlepath.circle.fill",
        "leaf.arrow.circlepath",
        "arrowtriangle.up.circle",
        "arrowtriangle.up.circle.fill",
        "arrowtriangle.down.circle",
        "arrowtriangle.down.circle.fill",
        "arrowtriangle.left.circle",
        "arrowtriangle.left.circle.fill",
        "arrowtriangle.right.circle",
        "arrowtriangle.right.circle.fill",
        "circle.fill",
        "circle.lefthalf.fill",
        "circle.righthalf.fill",
        "largecircle.fill.circle",
        "smallcircle.fill.circle",
        "smallcircle.fill.circle.fill",
        "smallcircle.circle",
        "smallcircle.circle.fill",
        "slash.circle",
        "slash.circle.fill",
        "asterisk.circle",
        "asterisk.circle.fill"
    ]
    
    static let images = imageNames.map { (str) -> AnyView in
        return AnyView(Image(systemName: str).renderingMode(.template).resizable().aspectRatio(contentMode: .fill))
    }
}

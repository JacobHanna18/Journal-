//
//  ViewController.swift
//  DoneTracker
//
//  Created by Jacob Hanna on 22/12/2020.
//

import UIKit
import SwiftUI

class FinishVC: UIViewController, Presenting, ObservableObject, UIDocumentPickerDelegate{
    
    @Published var done : [[Bool]] = [[Bool]](repeating: [Bool](repeating: false, count: 7), count: 6)
    
    var calender = Calender(month: Date().month, year: Date().year)
    
    
    func reload() {
        update()
        content.rootView.doneImage = Lists.selectedList.doneImageName
        content.rootView.undoneImage = Lists.selectedList.undoneImageName
        content.rootView.color = Color(Lists.selectedList.color)
    }
    
    func update(){
        self.navigationController?.view.tintColor = Lists.selectedList.color
        self.navigationItem.title = Lists.selectedList.name
        self.tabBarController?.tabBar.items?[1].selectedImage = UIImage(systemName: Lists.TabBarSelectedImageName)?.withRenderingMode(.alwaysTemplate)
        self.tabBarController?.tabBar.items?[1].image = UIImage(systemName: Lists.TabBarImageName)?.withRenderingMode(.alwaysTemplate)
        
    }
    static var main : FinishVC!

    @IBOutlet weak var calenderView: UIView!
    var content : UIHostingController<FinishCalenderView>!
    
    var calenderV : FinishCalenderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FinishVC.main = self
        if Lists.value.count == 0{
            Lists.newList()
        }
        calenderV = FinishCalenderView(calender: calender, tapMonth:{
            self.tapMonth()
        })
        
        update()
        setContent()
    }
    
    func setContent(){
        content = UIHostingController(rootView: calenderV)
        
        content.view.backgroundColor = UIColor.clear
        addChild(content)
        content.view.frame = calenderView.frame
        calenderView.addSubview(content.view)
        content.didMove(toParent: self)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.topAnchor.constraint(equalTo: calenderView.topAnchor).isActive = true
        content.view.bottomAnchor.constraint(equalTo: calenderView.bottomAnchor).isActive = true
        content.view.leftAnchor.constraint(equalTo: calenderView.leftAnchor).isActive = true
        content.view.rightAnchor.constraint(equalTo: calenderView.rightAnchor).isActive = true
    }
    
    @IBAction func selectMenu(_ sender: Any) {
        self.showForm({Lists.props})
    }
    
    func tapMonth (){
        let (yearC, monthC) = Lists.selectedList.getCountOf(year: self.calender.year, month: self.calender.month)
        let monthCell = FormCell(type: .IntSub, title: "Month Count", get: {
            return monthC
        })
        
        let yearCell = FormCell(type: .IntSub, title: "Year Count", get: {
            return yearC
        })
        
        let datePicker = FormCell(type: .DateInput(showTime: false, showDate: true), title: "Select Date") { (inp) in
            if let d = inp as? Date{
                self.calender.set(month: d.month, year: d.year)
            }
        } get: { () -> Any in
            return Day(self.calender.year, self.calender.month, Date().day).toDate
        }

        
        self.showForm {FormProperties(title: "\(Calender.months[self.calender.month - 1]) \(self.calender.year)", cells: [monthCell,yearCell, datePicker], button: .none)}

    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        do{
            let file = try String(contentsOf: urls[0], encoding: String.Encoding.utf8)
            Lists.newFrom(json: file)
            FormVC.top?.reload()
        }catch{
        }
        
    }

}


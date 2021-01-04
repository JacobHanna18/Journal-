//
//  ViewController.swift
//  DoneTracker
//
//  Created by Jacob Hanna on 22/12/2020.
//

import UIKit
import SwiftUI

class FinishVC: UIViewController, Presenting, ObservableObject, UIDocumentPickerDelegate{
    
    @Published var selectedList : Int = Lists.selectedIndex
    @Published var labels : [String] = Lists.value.map({ (l) -> String in
        return l.name
    })
    
    var calender = Calender(month: Date().month, year: Date().year)
    
    override func viewWillAppear(_ animated: Bool){
        reload()
        
    }
    
    func reload() {
        update()
        calenderHosting.rootView.doneImage = Lists.selectedList.doneImageName
        calenderHosting.rootView.undoneImage = Lists.selectedList.undoneImageName
        calenderHosting.rootView.color = Color(Lists.selectedList.listColor)
        
        calenderHosting.rootView.selectedIndex = Lists.selectedIndex
        
        selectedList = Lists.selectedIndex
        labels = Lists.value.map({ (l) -> String in
            return l.name
        })
    }
    
    func update(){
        self.view.tintColor = Lists.selectedList.listColor
        self.tabBarController?.tabBar.items?[1].selectedImage = UIImage(systemName: Lists.TabBarSelectedImageName)?.withRenderingMode(.alwaysTemplate)
        self.tabBarController?.tabBar.items?[1].image = UIImage(systemName: Lists.TabBarImageName)?.withRenderingMode(.alwaysTemplate)
        
    }
    static var main : FinishVC!

    var calenderV : FinishCalenderView!
    @IBOutlet weak var calenderView: UIView!
    var calenderHosting : UIHostingController<FinishCalenderView>!
    
    var titleV : FinishPageList!
    @IBOutlet weak var titleView: UIView!
    var titleHosting : UIHostingController<FinishPageList>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FinishVC.main = self
        if Lists.value.count == 0{
            Lists.newList()
        }
        calenderV = FinishCalenderView(calender: calender, tapMonth:{
            self.tapMonth()
        })
        
        titleV = FinishPageList(vc: self,selectionChanged: { (i) in
            Lists.selectedIndex = i
            self.reload()
        })
        
        
        update()
        setContent()
    }
    
    func setContent(){
        calenderHosting = UIHostingController(rootView: calenderV)
        
        calenderHosting.view.backgroundColor = UIColor.clear
        addChild(calenderHosting)
        calenderHosting.view.frame = calenderView.frame
        calenderView.addSubview(calenderHosting.view)
        calenderHosting.didMove(toParent: self)
        calenderHosting.view.translatesAutoresizingMaskIntoConstraints = false
        calenderHosting.view.topAnchor.constraint(equalTo: calenderView.topAnchor).isActive = true
        calenderHosting.view.bottomAnchor.constraint(equalTo: calenderView.bottomAnchor).isActive = true
        calenderHosting.view.leftAnchor.constraint(equalTo: calenderView.leftAnchor).isActive = true
        calenderHosting.view.rightAnchor.constraint(equalTo: calenderView.rightAnchor).isActive = true
        
        
        titleHosting = UIHostingController(rootView: titleV)
        
        titleHosting.view.backgroundColor = UIColor.clear
        addChild(titleHosting)
        titleHosting.view.frame = titleView.frame
        titleView.addSubview(titleHosting.view)
        titleHosting.didMove(toParent: self)
        titleHosting.view.translatesAutoresizingMaskIntoConstraints = false
        titleHosting.view.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        titleHosting.view.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        titleHosting.view.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        titleHosting.view.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
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
        
        let today = FormCell(type: .StringTitle(), title: "Today", tap:  {
            self.calender.set(month: Day().m, year: Day().y)
            FormVC.top?.dismiss(animated: true, completion: nil)
        })
        
        let datePicker = FormCell(type: .DateInput(showTime: false, showDate: true), title: "Select Date") { (inp) in
            if let d = inp as? Date{
                self.calender.set(month: d.month, year: d.year)
            }
        } get: { () -> Any in
            return Day(self.calender.year, self.calender.month, Date().day).toDate
        }

        
        self.showForm {FormProperties(title: "\(Calender.months[self.calender.month - 1]) \(self.calender.year)", cells: [monthCell,yearCell, datePicker, today], button: .none)}

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


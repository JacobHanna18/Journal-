//
//  calendarView.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 05/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit
enum MonthChangeType {
    case next, prev, random
}
protocol CalenderDelegate : class {
    
    func dayChanged (day :Day, old : Day, onCalender : Bool)
    func monthChanged (calender : Calender, type : MonthChangeType)
    func highlighted (day : Day) -> Bool
    
    func indecator (day : Day) -> Bool
}

class CalendarView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let inset : CGFloat = 2
    let daysHeight : CGFloat = 17
    
    let cellConrnerRaduis : CGFloat = 10
    let highlightedAlpha : CGFloat = 0.4
    
    let cellID = "calenderViewCellID"
    
    let dayTitles = ["Sun", "Mon", "Tue","Wed","Thu","Fri","Sat"]
    
    var selectedColor = UIColor.blue //sets to tint color at start
    var background : UIColor{
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
    var text : UIColor{
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
    var secondary : UIColor{
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.gray
        }
    }
    
    weak var calenderDelegate : CalenderDelegate? = nil
    
    var calender : Calender = Calender()
    var selectedDay = Day()
    
    override func awakeFromNib() {
        self.collectionViewLayout = createLayout ()
        delegate = self
        dataSource = self
        register(UINib(nibName: "Day Cell", bundle: nil), forCellWithReuseIdentifier: cellID)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        leftSwipe.direction = .left
        self.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        rightSwipe.direction = .right
        self.addGestureRecognizer(rightSwipe)
        selectedColor = tintColor
        getDates()
    }
    override func tintColorDidChange() {
        selectedColor = tintColor
        reloadData()
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right{
            prevMonth()
        }else if gesture.direction == .left{
            nextMonth()
        }
    }
    
    func select (day : Day){
        let old = selectedDay
        selectedDay = day
        set(month: day.m, year: day.y)
        calenderDelegate?.dayChanged(day: selectedDay, old: old, onCalender: false)
    }
    
    func nextMonth(){
        calender.nextMonth()
        self.reloadData()
        calenderDelegate?.monthChanged(calender: calender, type: .next)
    }
    
    func prevMonth(){
        calender.prevMonth()
        self.reloadData()
        calenderDelegate?.monthChanged(calender: calender, type: .prev)
    }
    
    func set (month m : Int? = nil, year y: Int? = nil){
        calender.set(month: m, year: y)
        getDates()
        calenderDelegate?.monthChanged(calender: calender, type: .random)
    }
    
    func getDates(){
        calender.getDates()
        reloadData()
    }
    
    //collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let old = selectedDay
            selectedDay = calender.days[indexPath.row]
            calenderDelegate?.dayChanged(day: calender.days[indexPath.row], old: old, onCalender: true)
            reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return calender.dayCount
        }else{
            return 7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DayCell
        let day = calender.days[indexPath.row]
        cell.layer.cornerRadius = cellConrnerRaduis
        
        if indexPath.section == 1{
            cell.indicatorView.backgroundColor = (calenderDelegate?.indecator(day: day) ?? false) && (Indicator.value) ? background : UIColor.clear
            cell.setLabel("\(day.d)")
            cell.label.font = UIFont.systemFont(ofSize: 17, weight: day == Day() ? .bold : .regular)
            if selectedDay == day{
                cell.backgroundColor = selectedColor
                cell.label.textColor = background
            }else{
                if (indexPath.row >= calender.start && indexPath.row <= calender.end){
                    cell.label.textColor = text
                }else{
                    cell.label.textColor = secondary
                }
                if (calenderDelegate?.highlighted(day: day) == true){
                    cell.backgroundColor = selectedColor.withAlphaComponent(highlightedAlpha)
                }else{
                    cell.backgroundColor = background
                }
                
            }
        }else{
            cell.label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            cell.indicatorView.backgroundColor = UIColor.clear
            cell.backgroundColor = background
            cell.label.textColor = text
            cell.setLabel(dayTitles[indexPath.row])
            cell.alpha = 1
        }
        
        return cell
    }
    
    func createLayout () -> UICollectionViewLayout{
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let inset = self.inset
            let rowheight = (self.frame.height - self.daysHeight)/CGFloat(self.calender.dayRows)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(sectionIndex == 0 ? self.daysHeight : rowheight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        return layout
    }

}










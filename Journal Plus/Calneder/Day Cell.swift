//
//  dayCell.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 05/07/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit

class DayCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var indicatorView: UIView!
    
    override func awakeFromNib() {
        indicatorView.layer.cornerRadius = indicatorView.frame.width / 2
    }
    
    func setLabel(_ txt : String){
        label.text = txt
    }

}

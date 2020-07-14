//
//  LabeledVC.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 07/11/2018.
//  Copyright © 2018 Jacob Hanna. All rights reserved.
//

import UIKit

class LabeledVC: UIViewController {

    @IBOutlet weak var label: UILabel!
    static let id = "labeledVC"
    
    var color = UIColor()
    var text = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.textColor = color
        label.text = text
    }
    
    func set (_ text : String, _ color : UIColor = AppTintColor.value){
        self.text = text
        self.color = color
    }

}

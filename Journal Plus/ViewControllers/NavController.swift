//
//  NavController.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 30/12/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit

class NavController: UITabBarController {
    
    static var nav : NavController?

    override func viewDidLoad() {
        super.viewDidLoad()
        NavController.nav = self
    }

}

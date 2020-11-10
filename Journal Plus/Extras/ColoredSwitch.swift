//
//  ColoredSwitch.swift
//  Journal Plus
//
//  Created by Jacob Hanna on 29/10/2020.
//  Copyright © 2020 Jacob Hanna. All rights reserved.
//

import UIKit

class ColoredSwitch: UISwitch {

    override public func awakeFromNib() {
        print("here")
        self.onTintColor = self.tintColor
    }
}

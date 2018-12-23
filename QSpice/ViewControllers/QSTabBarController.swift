//
//  QSTabBarController.swift
//  QSpice
//
//  Created by Anthony Fiorito on 2018-12-21.
//  Copyright © 2018 Anthony Fiorito. All rights reserved.
//

import UIKit

class QSTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = Colors.maroon
        tabBar.unselectedItemTintColor = Colors.darkGrey
    }
    
}

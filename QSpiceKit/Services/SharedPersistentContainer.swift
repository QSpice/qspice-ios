//
//  SharedPersistentContainer.swift
//  QSpiceKit
//
//  Created by Anthony Fiorito on 2019-03-24.
//  Copyright © 2019 Anthony Fiorito. All rights reserved.
//

import UIKit
import CoreData

class SharedPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.electriapp.QSpice")
        
        return storeURL!.appendingPathComponent("QSpice.sqlite")

    }
}

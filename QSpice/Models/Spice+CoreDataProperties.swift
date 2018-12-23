//
//  Spice+CoreDataProperties.swift
//  QSpice
//
//  Created by Anthony Fiorito on 2018-12-21.
//  Copyright © 2018 Anthony Fiorito. All rights reserved.
//
//

import Foundation
import CoreData

extension Spice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Spice> {
        return NSFetchRequest<Spice>(entityName: "Spice")
    }

    @NSManaged public var name: String
    @NSManaged public var weight: Float
    @NSManaged public var color: String
    @NSManaged public var slot: Int
    @NSManaged public var active: Bool

}

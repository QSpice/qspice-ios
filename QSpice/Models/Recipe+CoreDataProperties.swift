//
//  Recipe+CoreDataProperties.swift
//  QSpice
//
//  Created by Anthony Fiorito on 2018-12-22.
//  Copyright © 2018 Anthony Fiorito. All rights reserved.
//
//

import Foundation
import CoreData

extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var content: String?
    @NSManaged public var image: String?
    @NSManaged public var link: String?
    @NSManaged public var spices: NSSet?

}

// MARK: Generated accessors for spices
extension Recipe {

    @objc(addSpicesObject:)
    @NSManaged public func addToSpices(_ value: Spice)

    @objc(removeSpicesObject:)
    @NSManaged public func removeFromSpices(_ value: Spice)

    @objc(addSpices:)
    @NSManaged public func addToSpices(_ values: NSSet)

    @objc(removeSpices:)
    @NSManaged public func removeFromSpices(_ values: NSSet)

}

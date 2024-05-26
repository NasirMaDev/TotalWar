//
//  Entity+CoreDataProperties.swift
//  
//
//  Created by SilentSol PVT LTD on 18/11/2021.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "ImageData")
    }

    @NSManaged public var myimage: Data?

}

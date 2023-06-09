//
//  Vote+CoreDataProperties.swift
//  
//
//  Created by Ahmed Eslam on 07/06/2023.
//
//

import Foundation
import CoreData


extension Vote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vote> {
        return NSFetchRequest<Vote>(entityName: "Vote")
    }

    @NSManaged public var address: String?

}

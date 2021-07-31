//
//  GlobalData+CoreDataProperties.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-31.
//
//

import Foundation
import CoreData


extension GlobalData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GlobalData> {
        return NSFetchRequest<GlobalData>(entityName: "GlobalData")
    }

    @NSManaged public var view: String?

}

extension GlobalData : Identifiable {

}

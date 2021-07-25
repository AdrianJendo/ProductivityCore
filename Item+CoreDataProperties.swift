//
//  Item+CoreDataProperties.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-17.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var created: Date?
    @NSManaged public var order: Int64
    @NSManaged public var text: String?
    @NSManaged public var origin: TodoList?
    @NSManaged public var completed: Bool
    
    public var wrappedText: String {
        text ?? ""
    }
    
    public var wrappedCreated: Date {
        created ?? Date()
    }
}

extension Item : Identifiable {

}

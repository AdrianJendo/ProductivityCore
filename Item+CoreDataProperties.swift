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
    
    convenience public init(context: NSManagedObjectContext, list: TodoList) {
        self.init(context: context)
        self.text = ""
        self.created = Date()
        self.order = Int64(list.itemsArray.count)
        self.origin = list
        self.completed = false
    }
    
    convenience public init(context: NSManagedObjectContext, originalItem: Item) {
        self.init(context: context)
        self.text = originalItem.wrappedText
        self.created = originalItem.created
        self.order = originalItem.order
        self.origin = originalItem.origin
        self.completed = false
    }
    
    public var wrappedText: String {
        text ?? ""
    }
    
    public var wrappedCreated: Date {
        created ?? Date()
    }
}

extension Item : Identifiable {

}

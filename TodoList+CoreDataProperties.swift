//
//  TodoList+CoreDataProperties.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-17.
//
//

import Foundation
import CoreData


extension TodoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoList> {
        return NSFetchRequest<TodoList>(entityName: "TodoList")
    }

    @NSManaged public var created: Date?
    @NSManaged public var id: UUID
    @NSManaged public var order: Int64
    @NSManaged public var title: String?
    @NSManaged public var showCompleted: Bool
    @NSManaged public var showOnlyCompleted: Bool
    @NSManaged public var item: NSSet?
    
    public var wrappedTitle: String {
        title ?? "New List"
    }
    
    public var wrappedCreated: Date {
        created ?? Date()
    }
    
    public var itemsArray: [Item] {
        let set = item as? Set<Item> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }

}

// MARK: Generated accessors for item
extension TodoList {

    @objc(addItemObject:)
    @NSManaged public func addToItem(_ value: Item)

    @objc(removeItemObject:)
    @NSManaged public func removeFromItem(_ value: Item)

    @objc(addItem:)
    @NSManaged public func addToItem(_ values: NSSet)

    @objc(removeItem:)
    @NSManaged public func removeFromItem(_ values: NSSet)

}

extension TodoList : Identifiable {

}

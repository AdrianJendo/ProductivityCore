//
//  ContentView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-15.
//

import SwiftUI
import SwiftUIX

struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.created, ascending: true)])
//    private var items: FetchedResults<Item>
    
    @ObservedObject var list: TodoList
//    @State private var itemsArray: [Item]
    @State private var highlightIndex = -1
    
    var body: some View {
        //if let items = self.list.item?.allObjects as? [Item] {
//        let itemsArray = list.itemsArray
//        highlightIndex = itemsArray[itemsArray.count-1].text == "" ? itemsArray.count-1 : -1
        List {
            ForEach(list.itemsArray) { item in
                CocoaTextField("Todo Task", text: Binding<String>(get: {item.text ?? "<none>"}, set: {updateTodoItem(item, $0)}))
                    .isFirstResponder(list.itemsArray.firstIndex{ $0 == item } == highlightIndex)
                    .disableAutocorrection(true)
            }
            .onDelete(perform: deleteTodoItems)
        }
        .navigationTitle("Todo List")
        .navigationBarItems(trailing: Button("Add Task") {
            addTodoItem()
        })
    }
    
    private func saveContext() {
        do{
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    
    private func addTodoItem() {
        self.highlightIndex = self.list.itemsArray.count
        withAnimation{
            let newTodoItem = Item(context: viewContext)
            newTodoItem.text = ""
            newTodoItem.created = Date()
            newTodoItem.order = Int64(self.list.itemsArray.count)
            newTodoItem.origin = self.list
            
            saveContext()
        }
    }
    
    private func deleteTodoItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { self.list.itemsArray[$0] }.forEach(viewContext.delete)
//            for item in self.list.itemsArray {
//                item.order -= 1
//            }
            saveContext()
        }
    }
    
    private func updateTodoItem(_ item: FetchedResults<Item>.Element, _ text: String) {
//        if let items = self.list.item?.allObjects as? [Item] {
        self.highlightIndex = self.list.itemsArray.firstIndex{ $0 == item } ?? -1
        withAnimation {
            item.text = text
            saveContext()
        }
//        }
    }
}

//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoListView()
//    }
//}

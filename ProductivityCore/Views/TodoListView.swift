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
    @ObservedObject var list: TodoList
    @State private var highlightIndex = -1
    @State private var editMode: EditMode = .inactive

    var body: some View {
        List {
            ForEach(list.itemsArray) { item in
                CocoaTextField("Todo Task", text: Binding<String>(get: {item.text ?? "<none>"}, set: {updateTodoItem(item, $0)}))
                    .isFirstResponder(list.itemsArray.firstIndex{ $0 == item } == highlightIndex)
                    .disableAutocorrection(true)
                    .disabled(editMode == .active || editMode == .transient)
            }
            .onDelete(perform: deleteTodoItems)
            .onMove(perform: moveTodoItem)
        }
        .navigationBarTitle(list.wrappedTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if(editMode == .transient) {
                    Button("Cancel") {
                        editMode = .inactive
                    }
                }
                else {
                    EditButton()
                }

                Button(action: {
                    addTodoItem()
                }) {
                    Image(systemName: "plus.circle")
                }
                .disabled(editMode == .active || editMode == .transient)
            }
        }
        .environment(\.editMode, $editMode)
    }

    private func addTodoItem() {
        withAnimation{
            self.highlightIndex = self.list.itemsArray.count
            let newTodoItem = Item(context: viewContext)
            newTodoItem.text = ""
            newTodoItem.created = Date()
            newTodoItem.order = Int64(self.list.itemsArray.count)
            newTodoItem.origin = self.list
            PersistenceController.shared.save()
        }
    }
    
    private func deleteTodoItems(offsets: IndexSet) {
        withAnimation{
            for index in offsets {
                let itemsArray = self.list.itemsArray
                let item = itemsArray[index]
                // Decrement the subsequent orders so that we can sort use the order property to determine item order
                for i in (index+1) ..< itemsArray.count {
                    itemsArray[i].order -= 1
                }
                PersistenceController.shared.delete(item)
            }
        }
    }

    private func updateTodoItem(_ item: FetchedResults<Item>.Element, _ text: String) {
//        if let items = self.list.item?.allObjects as? [Item] {
        self.highlightIndex = self.list.itemsArray.firstIndex{ $0 == item } ?? -1
        withAnimation {
            item.text = text
            PersistenceController.shared.save()
        }
//        }
    }

    private func moveTodoItem(source: IndexSet, destination: Int) {
        var itemsArray = self.list.itemsArray
        itemsArray.move(fromOffsets: source, toOffset: destination)
        self.highlightIndex = source.first! < destination ? destination - 1 : destination

        for index in itemsArray.indices {
            itemsArray[index].order = Int64(index)
        }

        PersistenceController.shared.save()
    }

    private func checkOrder(_ arr: [Item]) {
        for i in arr {
            print(i.order)
        }
        print("----------")
    }
}


//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoListView()
//    }
//}

//
//  ContentView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-15.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.created, ascending: true)])
    private var items: FetchedResults<Item>
    @State private var isEditing = false
    @State private var text: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    TextField(
                        "Todo Task",
                        text: Binding<String>(get: {item.text ?? "<none>"}, set: {item.text = $0})
//                        text: $text
//                        ) { isEditing in
//                            self.isEditing = isEditing
//                        } onCommit: {
//                            updateTodoItem(item, text)
//                        }
//                        .autocapitalization(.none)
                    
//                    Text(item.text ?? "Untitled")
//                        .onTapGesture(count:1, perform: {
//                            updateTodoItem(item)
//                        }
                    )
                }.onDelete(perform: deleteTodoItems)
            }
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: Button("Add Task") {
                addTodoItem()
            })
        }.navigationViewStyle(StackNavigationViewStyle()) //Idk what it does but Removing this adds some errors
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
        withAnimation{
            let newTodoItem = Item(context: viewContext)
            newTodoItem.text = "New Task \(Date())"
            newTodoItem.created = Date()
            
            saveContext()
        }
    }
    
    private func deleteTodoItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func updateTodoItem(_ item: FetchedResults<Item>.Element, _ text: String) {
        withAnimation {
            item.text = text
            saveContext()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

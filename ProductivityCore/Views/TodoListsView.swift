//
//  ContentView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-15.
//

import SwiftUI
import SwiftUIX

struct TodoListsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: TodoList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TodoList.created, ascending: true)])
    private var todoLists: FetchedResults<TodoList>
    
    var body: some View {
        NavigationView {
            List{
                ForEach(todoLists) { list in
                    NavigationLink(list.wrappedTitle, destination: TodoListView(list: list)) //todoListViewModel: TODOListViewModel(todoList: list)
//                        Spacer()
//                        Button(action: {
//                            todoListsViewModel.remove(list.id)
//                        }) {
//                            Image(systemName: "trash")
//                        }
                }
                .onDelete(perform: deleteTodoList)
            }
            .navigationTitle("Todo Lists")
            .navigationBarItems(trailing: Button("Add a New Todo List") {
                addTodoList()
            })
        }.navigationViewStyle(StackNavigationViewStyle()) //Idk what it does but Removing this adds some errors
    }
    
    func addTodoList() {
        withAnimation{
            let newTodoList = TodoList(context: viewContext)
            newTodoList.title = "New Item"
            newTodoList.created = Date()
            newTodoList.id = UUID()
            newTodoList.order = Int64(todoLists.count)
            let firstItem = Item(context: viewContext)
            firstItem.text = ""
            firstItem.created = Date()
            firstItem.origin = newTodoList
            PersistenceController.shared.save()
        }
    }
    
    private func deleteTodoList(offsets: IndexSet) {
        withAnimation{
            for index in offsets {
                let todoList = todoLists[index]
                PersistenceController.shared.delete(todoList)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListsView()
    }
}

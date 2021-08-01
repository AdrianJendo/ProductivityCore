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
    @FetchRequest(entity: TodoList.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TodoList.order, ascending: true)])
    private var todoLists: FetchedResults<TodoList>
    @State private var editMode: EditMode = .inactive // Current state of EditMode used to handle editing
    @State private var popupTitle = "" // Binding for when editing todolist title
    @State private var popupType: PopupTypes = .cancel // Status of popup
    @State private var showPopup = false // Boolean needed to check on change of previous variable
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(todoLists, id:\.self) { list in
                        NavigationLink(list.wrappedTitle, destination: TodoListView(list: list))
                            .height(40)
                    }
                    .onDelete(perform: deleteTodoList)
                    .onMove(perform: moveTodoList)
                }
                .navigationTitle("Todo Lists")
                .overlay(Text("Add A New Todo List")
                            .font(.system(size: 32, weight: .thin))
                            .opacity(todoLists.count > 0 ? 0 : 1)
                )
                .environment(\.editMode, $editMode)
                .onChange(of: showPopup, perform: { value in
                    if popupType == .done {
                        if(popupTitle == ""){
                            popupTitle = "New Item"
                        }
                        addTodoList(popupTitle)
                    }
                    popupTitle = ""
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if(editMode == .transient) {
                            Button("Cancel") {
                                editMode = .inactive
                            }
                        }
                        else {
                            Button(action: {
                                withAnimation {
                                    editMode.toggle()
                                }
                            }) {
                                Text(editMode == .active ? "Done" : "Edit")
                            }
                        }
                        Button(action: {
                            popupType = .open
                            showPopup = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(editMode == .active || editMode == .transient)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Text("")
                            .height(55)
                            .width(500)
                            .backgroundFill(Color.systemBackground)
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle()) //Idk what it does but Removing this adds some errors I think
            Popup(title: "Add a New Todo List", placeholder: "New Todo List", show: $showPopup, popupStatus: $popupType, text: $popupTitle)
        }
    }

    // Add a new todo item
    func addTodoList(_ title: String) {
        withAnimation{
            _ = TodoList(context: viewContext, title: title, numLists: todoLists.count)
            PersistenceController.shared.save()
        }
    }

    // Delete a todo list
    private func deleteTodoList(offsets: IndexSet) {
        withAnimation{
            for index in offsets {
                let todoList = todoLists[index]
                // Decrement the subsequent orders so that we can sort use the order property to determine item order
                for i in (index+1) ..< todoLists.count {
                    todoLists[i].order -= 1
                }
                PersistenceController.shared.delete(todoList)
            }
        }
    }

    // Change todo order
    private func moveTodoList(source: IndexSet, destination: Int) {
        var newTodoOrder: [TodoList] = todoLists.map{$0} // Shallow copy or something
        newTodoOrder.move(fromOffsets: source, toOffset: destination)
        // Traverse entire list and reindex everything based on new order
        for index in newTodoOrder.indices {
            newTodoOrder[index].order = Int64(index)
        }
        PersistenceController.shared.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListsView()
    }
}

//
//  TodoListRowView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-25.
//

import SwiftUI
import SwiftUIX

struct TodoListRowView: View {
    @State var list: TodoList //Full list
    @State var item: Item //List item
    @State var completed: Bool
    @Binding var numCompleted: Int
    @Binding var showCompleted: Bool
    @Binding var editMode: EditMode
    @Binding var highlightIndex: Int
    
    
    var body: some View {
        HStack {
            if showCompleted || !completed {
                Circle()
                    .stroke(Color.orange, lineWidth: 2)
                    .background(Circle().fill(completed ? Color.orange : Color.systemBackground))
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 5)
                    .onTapGesture {
                        withAnimation {
                            if completed {
                                numCompleted -= 1
                            }
                            else {
                                numCompleted += 1
                            }
                            completed.toggle()
                            item.completed.toggle()
                            PersistenceController.shared.save()
                        }
                    }
                
                CocoaTextField("Todo Task", text: Binding<String>(get: {item.text ?? "<none>"}, set: {updateTodoItem(item, $0)}))
                    .isFirstResponder(list.itemsArray.firstIndex{ $0 == item } == highlightIndex)
                    .disableAutocorrection(true)
                    .disabled(editMode == .active || editMode == .transient)
            }
        }
    }
    
    // Change text of item
    private func updateTodoItem(_ item: FetchedResults<Item>.Element, _ text: String) {
        //        if let items = self.list.item?.allObjects as? [Item] {
        self.highlightIndex = self.list.itemsArray.firstIndex{ $0 == item } ?? -1
        withAnimation {
            item.text = text
            PersistenceController.shared.save()
        }
        //        }
    }
}


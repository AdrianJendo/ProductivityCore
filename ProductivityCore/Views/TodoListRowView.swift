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
    @State private var animationDone = false
    @State private var isEditing = false
    
    
    var body: some View {
        HStack {
            if !animationDone || showCompleted || !completed {
                ZStack {
                    Circle()
                        .stroke(completed ? Color.orange : Color(UIColor.lightGray), lineWidth: 1.5)
//                        .background(Circle().fill(completed ? Color.orange : Color.systemBackground))
                        .frame(width: 25, height: 25)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                        .opacity(completed ? 1 : 0)
                        .animation(Animation.easeInOut)
                }
                .padding(.trailing, 5)
                .onTapGesture {
                    completed.toggle()
                    animationDone = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            animationDone = true
                            if completed {
                                numCompleted += 1
                            }
                            else {
                                numCompleted -= 1
                            }
                            item.completed.toggle()
                            PersistenceController.shared.save()
                        }
                    }
                }
                .disabled(editMode != .inactive)
                
                CocoaTextField("Todo Task", text: Binding<String>(get: {item.text ?? ""}, set: {updateTodoItem(item, $0)}), onCommit: {
                    highlightIndex = -1
                 })
                    .isFirstResponder(list.itemsArray.firstIndex{ $0 == item } == highlightIndex)
                    .height(40)
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


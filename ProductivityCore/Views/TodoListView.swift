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
//    @Environment(\.popupTypes) private var popupTypes
    @ObservedObject var list: TodoList // List item passed in from TodoListsView
    @State private var highlightIndex = -1 // Highlighted index when updating a field
    @State private var editMode: EditMode = .inactive // Current state of EditMode used to handle editing
    @State private var showNavBarTitle = false // true when we should show the top navbar
    @State private var navTitle = "" // Binding for when editing todolist title
    @State private var editTitlePopup = false // Boolean to determine whether to show the popup
    @State private var popupType: PopupTypes = .cancel

    var body: some View {
        ZStack{
            List {
                //            let stringWidth = navTitle.widthOfString(usingFont: UIFont.systemFont(ofSize: 35, weight: .bold))
                //            let defaultText = "List Title"
                //            let minWidth = defaultText.widthOfString(usingFont: UIFont.systemFont(ofSize: 35, weight: .bold))
                //            let width = stringWidth < 280 ? stringWidth > minWidth ? stringWidth : minWidth : 280
                //            if editMode == .active {
                //                HStack {
                //                    ZStack {
                //                        Image(systemName: "square.and.pencil")
                //                            .foregroundColor(.systemBlue)
                //                            .font(.system(size: 25, weight: .bold))
                //                            .padding(.top, 2)
                //                            .padding(.leading, width+15)
                //                        TextField(
                //                            defaultText,
                //                            text: $navTitle,
                //                            onCommit: {
                //                                self.list.title = navTitle
                //                            }
                //                        )
                //                        .font(.system(size: 35, weight:.bold))
                //                        .frame(width: width+40)
                //                    }
                //                }
                //                .padding(.vertical, -10)
                //                }
                ForEach(list.itemsArray) { item in
                    CocoaTextField("Todo Task", text: Binding<String>(get: {item.text ?? "<none>"}, set: {updateTodoItem(item, $0)}))
                        .isFirstResponder(list.itemsArray.firstIndex{ $0 == item } == highlightIndex)
                        .disableAutocorrection(true)
                        .disabled(editMode == .active || editMode == .transient)
                }
                .onDelete(perform: deleteTodoItems)
                .onMove(perform: moveTodoItem)
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.principal) {
                    HStack{
                        Text(navTitle)
                            .font(Font.headline.weight(.semibold))
                        if editMode == .active {
                            Button(action: {
                                withAnimation(.linear(duration: 0.3)) {
                                    popupType = .open
                                }
                            }) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if editMode == .transient {
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
            .navigationBarTitleDisplayMode(.inline)
            //        .navigationBarTitleDisplayMode(editMode == .active ? .inline : .large)
            .environment(\.editMode, $editMode)
            .onAppear(perform: setHighlightIndex)
            .onDisappear(perform: {
                self.list.title = navTitle
            })
            .overlay(
                Text("Add A New Item")
                    .font(.system(size: 32, weight: .thin))
                    .opacity(list.itemsArray.count > 0 ? 0 : 1)
            )
//            .onChange(of: navTitle) { value in
//                self.list.title = navTitle
//                PersistenceController.shared.save()
//            }
//            .onChange(of: popupType){
//                print(popupType)
//            }
            Popup(title: "Change List Title", name: list.wrappedTitle, show: $popupType)
                .frame(alignment: .top)
        }
    }

    // Add new item
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

    // Delete item
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

    // Change order
    private func moveTodoItem(source: IndexSet, destination: Int) {
        var itemsArray = self.list.itemsArray
        itemsArray.move(fromOffsets: source, toOffset: destination)
        self.highlightIndex = source.first! < destination ? destination - 1 : destination

        for index in itemsArray.indices {
            itemsArray[index].order = Int64(index)
        }

        PersistenceController.shared.save()
    }

    // Sets the value of highlight index on view load
    // Currently sets index to last empty index, but considering just changing to to last index if its empty
    private func setHighlightIndex() {
        self.navTitle = self.list.wrappedTitle
        let itemsArray = self.list.itemsArray
        if let lastEmptyIndex = itemsArray.lastIndex(where: { $0.text == ""}) {
            DispatchQueue.main.async {
                self.highlightIndex = lastEmptyIndex
            }
        }
    }

    // Helper function just to make sure the order doesn't get messed up (not used in prod)
    private func checkOrder(_ arr: [Item]) {
        for i in arr {
            print(i.order)
        }
        print("----------")
    }
}

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}


//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoListView()
//    }
//}

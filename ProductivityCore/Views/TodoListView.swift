//
//  ContentView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-15.
//

import SwiftUI

struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var list: TodoList // List item passed in from TodoListsView
    @State private var highlightIndex = -1 // Highlighted index when updating a field
    @State private var editMode: EditMode = .inactive // Current state of EditMode used to handle editing
    @State private var popupTitle = "" // Binding for when editing todolist title
    @State private var popupType: PopupTypes = .cancel // Status of popup
    @State private var showPopup = false // Boolean needed to check on change of previous variable
    @State private var numCompleted = 0 // Number of completed todo items
    @State private var addButtonDelay = false // Boolean used to disable add button between item additions
    @State private var deleteCompletedPopup = false // Boolean for checking if deleteCompleted todos popup should be open
    
    var body: some View {
        ZStack{
            VStack {
                List {
                    ForEach(list.itemsArray, id:\.self) { item in
                        if (list.showCompleted && !list.showOnlyCompleted) || //Try simplify with boolean algebra at some point
                            (list.showCompleted && list.showOnlyCompleted && item.completed) ||
                            (!list.showCompleted && !item.completed)
                        {
                            TodoListRowView(list: list, item: item, completed: item.completed, numCompleted:$numCompleted, showCompleted:$list.showCompleted, editMode: $editMode, highlightIndex: $highlightIndex)
                        }
                    }
                    .onDelete(perform: deleteTodoItems)
                    .onMove(perform: moveTodoItem)
                }
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.principal) {
                        HStack{
                            Text(list.wrappedTitle)
                                .font(Font.headline.weight(.semibold))
                            if editMode == .active {
                                Button(action: {
                                    withAnimation(.linear(duration: 0.3)) {
                                        popupType = .open
                                        showPopup = true
                                    }
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                .disabled(showPopup)
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
                            EditButton().onPress {
                                if editMode == .active {
                                    popupType = .done
                                    showPopup = false
                                }
                                withAnimation {
                                    editMode.toggle()
                                }
                            }
                        }
                        
                        Button(action: {
                            addTodoItem()
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(editMode != .inactive || addButtonDelay)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .onAppear(perform: initializeList)
                .overlay(
                    Text("Add A New Item")
                        .font(.system(size: 32, weight: .thin))
                        .opacity(list.itemsArray.count > 0 ? 0 : 1)
                )
                .onChange(of: showPopup) { value in
                    if popupType != .cancel {
                        self.list.title = popupTitle
                        PersistenceController.shared.save()
                    }
                    else {
                        popupTitle = self.list.wrappedTitle
                    }
                }
                .navigationBarBackButtonHidden(showPopup)
                Divider()
                if numCompleted > 0 {
                    VStack (spacing: 10) {
                        if list.showCompletedFooter && list.showCompleted {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        deleteCompletedPopup = true
                                    }
                                }) {
                                    Text("\(Image(systemName: "xmark.bin"))")
                                }
                                .frame(maxWidth: .infinity)
                                Divider()
                                    .frame(height: 20)
                                Button(action: {
                                    withAnimation {
                                        list.showOnlyCompleted.toggle()
                                        PersistenceController.shared.save()
                                    }
                                }) {
                                    Text("\(list.showOnlyCompleted ? "Hide" : "Show") Only \(Image(systemName: "list.bullet"))")
                                }
                                .frame(maxWidth: .infinity)
                                Divider()
                                    .frame(height: 20)
                                Button(action: {
                                    resetToIncomplete()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(0)
                            Divider()
                                .padding(0)
                        }
                        ZStack {
                            Button(action: {
                                withAnimation {
                                    list.showCompleted.toggle()
                                    PersistenceController.shared.save()
                                }
                            }) {
                                Text("\(list.showCompleted ? "Hide" : "Show") Completed (\(numCompleted))")
                            }
                            .padding(.top, 10)
                            if list.showCompleted {
                                Button(action: {
                                    withAnimation {
                                        list.showCompletedFooter.toggle()
                                        PersistenceController.shared.save()
                                    }
                                }) {
                                    Image(systemName: "arrow.up")
                                }
                                .rotationEffect(Angle.degrees(list.showCompletedFooter ? 180 : 0))
                                .animation(Animation.easeInOut)
                                .offset(x: 160)
                                .padding(.top, 10)
                            }
                        }
                    }
                }
            }
            Popup(title: "Change List Title", placeholder: "New List Name", show: $showPopup, popupStatus: $popupType, text: $popupTitle)
            ConfirmPopup(title: "Delete Completed Items", text: "Are you sure you want to \n delete these items?", show: $deleteCompletedPopup, onConfirm: {self.removeCompleted()})
        }
    }

    // Add new item
    private func addTodoItem() {
//        checkOrder(self.list.itemsArray)
        withAnimation{
            addButtonDelay = true
            self.highlightIndex = self.list.itemsArray.count
            _ = Item(context: viewContext, list: self.list)
            PersistenceController.shared.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay prevents spamming items which could cause unwanted consequences
                addButtonDelay = false
            }
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
                if item.completed {
                    self.numCompleted -= 1
                    if numCompleted == 0 {
                        self.list.showOnlyCompleted = false
                    }
                }
                PersistenceController.shared.delete(item)
            }
        }
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
    private func initializeList() {
        self.popupTitle = self.list.wrappedTitle
        let itemsArray = self.list.itemsArray
        for item in itemsArray {
            if item.completed {
                self.numCompleted += 1
            }
        }
        if let lastEmptyIndex = itemsArray.lastIndex(where: { $0.text == ""}) {
            DispatchQueue.main.async {
                self.highlightIndex = lastEmptyIndex
            }
        }
    }
    
    private func removeCompleted() {
        let filtered = self.list.itemsArray.filter({ $0.completed })
        
        withAnimation {
            let itemsArray = self.list.itemsArray
            for item in filtered {
                if let index = itemsArray.firstIndex(of: item){
                    for i in (index+1) ..< itemsArray.count {
                        itemsArray[i].order -= 1
                    }
                }
                PersistenceController.shared.delete(item)
            }
            self.numCompleted = 0
            self.list.showOnlyCompleted = false
        }
    }
    
    private func resetToIncomplete() {
        let filtered = self.list.itemsArray.filter({ $0.completed })

        withAnimation {
            self.numCompleted = 0
            self.list.showOnlyCompleted = false
        }

        for item in filtered {
            _ = Item(context: viewContext, originalItem: item)
            PersistenceController.shared.delete(item)
        }
    }

    // Helper function just to make sure the order doesn't get messed up (not used in prod)
    private func checkOrder(_ arr: [Item]) {
        var cur = 0
        for item in arr {
            assert(item.order == cur, "ORDER INCORRECT")
            cur += 1
        }
        print("Check Completed Successfully")
    }
}

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

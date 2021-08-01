//
//  TabView.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-31.
//

import SwiftUI

struct TabsView: View {
    @State private var selectedTab = 1 // Will be stored in coredata under GlobalData
    var body: some View {
        TabView(selection: $selectedTab) {
            TodoListsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                }
                .tag(1)
            Text("Calendar Screen")
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(2)
            Text("Reminders Screen")
                .tabItem {
                    Image(systemName: "bell.badge")
                }
                .tag(3)
        }
    }
}

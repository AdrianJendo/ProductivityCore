//
//  Popup.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-24.
//

import SwiftUI
import SwiftUIX

struct Popup: View {
    var title: String
    var name: String
    @Binding var show: PopupTypes
    @State var text = ""
    
    var body: some View {
        ZStack {
            if show == .open {
                // PopUp background color
                Color.black.opacity(show == .open ? 0.3 : 0).edgesIgnoringSafeArea(.all)

                // PopUp Window
                VStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.system(size: 16, weight: .semibold))
                    .padding()
                    
                    Divider()
                    
//                    CocoaTextField("New List Name", text: $textFieldTitle, isEditing: .constant(true))
//                        .isFirstResponder(true)
//                        .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25))
//                        .background(Color.systemBackground)
//                        .selectAll(nil)
                    FirstResponderTextField(text: $text, placeholder: "New List Name")
                        .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25))
                        .background(Color.systemBackground)
                    
                    Divider()

                    HStack {
                        Spacer()
                        Button(action: {
                            // Dismiss the PopUp
                            withAnimation(.linear(duration: 0.3)) {
                                show = .cancel
                            }
                        }, label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        })
                        
                        Divider()
                        
                        Button(action: {
                            // Dismiss the PopUp
                            withAnimation(.linear(duration: 0.3)) {
                                show = .done
                            }
                        }, label: {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                        })
                        Spacer()
                    }
                    .padding()
                    
                }
                .background(Color.secondarySystemBackground)
                .cornerRadius(25)
                .frame(maxWidth: 300, maxHeight: 100, alignment: .topLeading)
                .onAppear(perform: {
                    text = name
                })
            }
        }
    }
}

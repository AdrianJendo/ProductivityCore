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
    var placeholder: String
    @Binding var show: Bool
    @Binding var popupStatus: PopupTypes
    @Binding var text: String
    
    var body: some View {
        ZStack {
            if show {
                // PopUp background color
                Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)

                // PopUp Window
                VStack(spacing: 0) {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.system(size: 16, weight: .semibold))
                    .padding()
                    
                    Divider()

                    FirstResponderTextField(text: $text, placeholder: placeholder)
                        .padding(EdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25))
                        .background(Color.systemBackground)
                    
                    Divider()

                    HStack {
                        Spacer()
                        Button(action: {
                            // Dismiss the PopUp
                            withAnimation(.linear(duration: 0.3)) {
                                show = false
                                popupStatus = .cancel
                            }
                        }, label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        })
                        
                        Divider()
                        
                        Button(action: {
                            // Dismiss the PopUp
                            withAnimation(.linear(duration: 0.3)) {
                                show = false
                                popupStatus = .done
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
                .cornerRadius(10)
                .frame(maxWidth: 300, maxHeight: 100)
            }
        }
    }
}

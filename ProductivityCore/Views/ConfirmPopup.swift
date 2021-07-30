//
//  ConfirmPopup.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-29.
//

import SwiftUI

struct ConfirmPopup: View {
    var title: String
    var text: String
    @Binding var show: Bool
    var onConfirm: () -> Void

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
                        .padding(.top, 20)

                    Text(text)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.system(size: 14, weight: .light))
                        .padding()

                    Divider()

                    HStack {
                        Spacer()
                        Button(action: {
                            // Dismiss the PopUp
                            withAnimation(.linear(duration: 0.3)) {
                                show = false
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
                                onConfirm()
                            }
                        }, label: {
                            Text("Confirm")
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

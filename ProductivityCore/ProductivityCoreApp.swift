//
//  ProductivityCoreApp.swift
//  ProductivityCore
//
//  Created by Adrian Jendo on 2021-07-15.
//

import SwiftUI

@main
struct ProductivityCoreApp: App {
    
    let persistanceContainer = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, persistanceContainer.container.viewContext)
        }
    }
}

enum PopupTypes {
    case open
    case done
    case cancel
}

struct FirstResponderTextField: UIViewRepresentable {
    
    @Binding var text: String
    let placeholder: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        var becameFirstResponder = false
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.text = text
        return textField
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !context.coordinator.becameFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.becameFirstResponder = true
        }
    }
}

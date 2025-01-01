//
//  SignUpView.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import SwiftUI

struct SignUpView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var email = ""
    @State private var showPaswordView = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack{
            Form{
                TextField("Name", text: $name)
                TextField("Email", text: $email).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.emailAddress)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red)
                }
                
                Button("Continue"){
                    if isValidEmail(email){
                        showPaswordView = true
                    } else {
                        errorMessage = AttendanceError.invalidEmail.message
                    }
                }
            }.navigationTitle("Sign Up").navigationDestination(isPresented: $showPaswordView) {
                PasswordView(name:name, email: email)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: email.utf16.count)
        let matches = detector?.matches(in: email, options: [], range: range)
        
        return   matches?.count == 1 && matches?.first?.url?.scheme == "mailto"
    }
}

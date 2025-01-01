//
//  PasswordView.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import SwiftUI

struct PasswordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let name: String
    let email: String
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showLogin = false
    
    
    var body: some View {
        Form{
            SecureField("Password", text:$password)
            
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundStyle(.red)
            }
            
            Button("Create Account"){
                showLogin = true
                let employee = Employee(name: name, email:email, password: password)
                modelContext.insert(employee)
                
            }
        }.navigationTitle("Create Password").navigationDestination(isPresented: $showLogin){
            LoginView()
        }
    }
}

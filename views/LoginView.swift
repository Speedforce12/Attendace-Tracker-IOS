//
//  LoginView.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var employees: [Employee]
    
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var email = ""
    @State private var navigateToHome = false
    @State private var authenticatedEmployee: Employee?
    
    var body: some View {
        NavigationStack{
            Form{
                TextField("Email", text: $email).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.emailAddress)
                SecureField("Password", text:$password)

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red)
                }
                
                Button("Log In"){
                    authenticateUser()
                }

            }.navigationTitle("Log In")
                .navigationDestination(isPresented: $navigateToHome){
                    if let employee = authenticatedEmployee {
                        HomeView(employee: employee)
                    }
                }.toolbar{
                    ToolbarItem(placement: .topBarTrailing){
                        NavigationLink("Sign Up"){
                            SignUpView()
                        }
                    }
                }
        }
    }
    
    private func authenticateUser(){
        
        let employeeCredentials = Dictionary(uniqueKeysWithValues: employees.map {($0.email, $0)})
        if let employee = employeeCredentials[email], employee.password == password {
            authenticatedEmployee = employee
            errorMessage = ""
            navigateToHome = true
 
        } else {
            errorMessage = AttendanceError.invalidCredentials.message
        }
    }
}

#Preview {
    LoginView()
}

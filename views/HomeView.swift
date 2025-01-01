//
//  HomeView.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import SwiftUI
import LocalAuthentication

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    @State private var currentEmployee: Employee
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var showBiometric = false
    
    
    init(employee: Employee){
        _currentEmployee = State(initialValue: employee)
    }
    
    var body: some View {
        VStack(spacing: 20){
            Text("Welcome \(currentEmployee.name)").font(.title)
            
            Button("Check In"){
                Task{
                    await handleAttendance(type: .checkIn)                }
            }.buttonStyle(.borderedProminent)
            
            Button("Check Out"){
                Task {
                    await handleAttendance(type: .checkOut)                }
            }.buttonStyle(.borderedProminent)
            
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundStyle(.red)
            }
            
        }.padding().alert("Attention, you must register your Biometric", isPresented: $showAlert){
            Button("Register") {
                Task{
                    await registerBiometric()
                }
            }
            Button("Cancel", role: .cancel){}
        }.alert("Face ID set needed", isPresented: $showBiometric){
            Button("Open Settings"){
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel){}
        } message: {
            Text("Please set up your face ID")
        }
        
    }
    
    private func checkAndHandleBiometricRegistration(){
        let status = BiometricManager.shared.checkBiometricStatus()
        
        switch status{
        case .available:
            Task{
                await registerBiometric()
            }
            
        case .notEnrolled:
            showBiometric  = true
            
        case .notAvailable:
            errorMessage = "No Biometric available on this device"
            
        }
    }
    
    private func registerBiometric() async {
        
        do {
            if try await BiometricManager.shared.authenticate(reason: "Register Face ID to take Attendance"){
                currentEmployee.hasBiometric = true
                errorMessage = "Face ID registered"
            }
            
        } catch {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotEnrolled:
                    showBiometric = true
                    
                case .userCancel:
                    errorMessage = "Registration cancelled"
                    
                default:
                    errorMessage = "Failed to register Face ID"
                }
            } else {
                errorMessage = "Failed to register Face ID"
            }
        }
        
        
    }
    
    private func handleAttendance(type: AttendanceType) async {

        
        do {
            
            if !currentEmployee.hasBiometric {
                errorMessage = ""
                showAlert = true
                return
            }
            
            guard try await BiometricManager.shared.authenticate() else {
                throw AttendanceError.biometricMismatch
            }
            
            locationManager.checkOfficeLocation()
            guard locationManager.isWithinOffice else {
                throw AttendanceError.locationOutofRange
            }
            
            let calender = Calendar.current
            let today = calender.startOfDay(for: Date())
            
            let existingRecord = currentEmployee.attendance.first {
                record in calender.isDate(record.date, inSameDayAs: today) && record.type == type
            }
            
            if existingRecord != nil {
                throw type == .checkIn ? AttendanceError.alreadyCheckedIn : AttendanceError.alreadyCheckedOut
            }
            
            let location = Location(latitude: 37.7749, longitude: -122.4194)
            let record = Attendance(type:type, date:   Date(), location: location)
            currentEmployee.attendance.append(record)
            
            errorMessage = ""
        } catch {
            if let attendanceError = error as? AttendanceError {
                errorMessage = attendanceError.message
            } else {
                errorMessage = "Unexpected error occured"
            }
        }
    }
}


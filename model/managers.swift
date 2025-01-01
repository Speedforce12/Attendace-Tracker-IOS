//
//  managers.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import Foundation
import LocalAuthentication
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private let officeLocation = CLLocation(latitude: 37.7749, longitude: -123.4194)
    private let maxDistance: CLLocationDistance = 100
    
    @Published var isWithinOffice: Bool = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkOfficeLocation(){
        manager.requestLocation()
    }
    
    func locationManger(_ manager: CLLocationManager, didUpdateLocation locations: [CLLocation]){
        guard let location = locations.first else {return}
        let distance  = location.distance(from: officeLocation)
        isWithinOffice = distance <= maxDistance
    }
    
    func locationManger(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location error: \(error.localizedDescription)")
    }
    
}

class BiometricManager{
    static let shared  = BiometricManager()
    private var context = LAContext()
    private var error: NSError?
    
    func canUseBiometric() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func getBiometricType() -> LABiometryType {
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error);       return context.biometryType
    }
    
    func checkBiometricStatus() -> BiometricStatus {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    
        if let error = error {
            switch error.code {
            case LAError.biometryNotEnrolled.rawValue:
                return .notEnrolled
                
            case LAError.biometryNotAvailable.rawValue:
                return .notEnrolled
                
            default:
                return .notAvailable
            }
        }
        
        return canEvaluate ? .available : .notAvailable
    }
    
    func authenticate(reason: String = "Verify your Identity") async throws -> Bool {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw error ?? NSError(domain:"BiometricManager", code: -1)
            
        }
  
        
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            throw error
        }
    }
}

enum AttendanceError: Error {
    case invalidEmail
    case invalidCredentials
    case biometricNotRegistered
    case biometricMismatch
    case locationOutofRange
    case alreadyCheckedIn
    case alreadyCheckedOut
    
    var message: String {
        switch self {
        case.invalidEmail:
            return "Please check the format of your emai"
            
        case.invalidCredentials:
            return "Please check your email or password"
            
        case .biometricNotRegistered:
            return "You must first register your biometrics"
            
        case .biometricMismatch:
            return "Biometric failed"
            
        case.locationOutofRange:
            return "You must be in the office"
            
        case .alreadyCheckedIn:
            return "You have already checked in"
            
        case .alreadyCheckedOut:
            return "You already checked out"
        }
        
    }
}


enum BiometricStatus {
    case available
    case notAvailable
    case notEnrolled
}

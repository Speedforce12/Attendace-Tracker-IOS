//
//  datamodel.swift
//  Tracker
//
//  Created by speedy on 12/26/24.
//

import Foundation
import SwiftData

@Model
class Employee {
    var id: UUID
    var name: String
    var email: String
    var password: String
    var hasBiometric: Bool
    var attendance: [Attendance]
    
    init (name: String, email: String, password: String){
        self.id = UUID()
        self.email = email
        self.password = password
        self.hasBiometric = false
        self.attendance = []
        self.name = name
    }
}

@Model
class Attendance {
    var id: UUID
    var type: AttendanceType
    var date: Date
    var location: Location
 
    
    init (type: AttendanceType, date: Date, location: Location){
        self.id = UUID()
        self.type = type
        self.date = date
        self.location = location
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

enum AttendanceType: String, Codable {
    case checkIn
    case checkOut
}

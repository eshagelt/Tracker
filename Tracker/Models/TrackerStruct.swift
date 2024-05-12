//
//  TrackerStruct.swift
//  Tracker
//
//  Created by Анастасия on 21.02.2024.
//

import UIKit

struct Tracker: Hashable {
    let title: String
    let emoji: String
    let color: UIColor
    let id: UUID
    let trackerType: type
    let timetable: [Weekday]
    
    enum type {
        case singleEvent
        case habit
    }
    
    init(singleEventTitle: String, emoji: String, color: UIColor) {
        self.title = singleEventTitle
        self.emoji = emoji
        self.color = color
        self.id = UUID()
        self.trackerType = .singleEvent
        self.timetable = weekDays
    }
    
    init(habitTitle: String, emoji: String, color: UIColor, timetable: [Weekday]) {
        self.title = habitTitle
        self.emoji = emoji
        self.color = color
        self.id = UUID()
        self.trackerType = .habit
        self.timetable = timetable        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
        
}

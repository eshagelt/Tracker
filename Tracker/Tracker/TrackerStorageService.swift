//
//  TrackerStorageService.swift
//  Tracker
//
//  Created by Анастасия on 18.03.2024.
//

import UIKit

final class TrackerStorageService {
    static let shared = TrackerStorageService()
    static let didChageCompletedTrackers = Notification.Name(rawValue: "CompletedTrackersDidChange")
    
    private var categories: Set<TrackerCategory>
    private var records: Set<TrackerRecord> {
        didSet {
            NotificationCenter.default.post(Notification(name: TrackerStorageService.didChageCompletedTrackers, object: Array(self.records)))
        }
    }
    
    init(categories: Set<TrackerCategory> = [], records: Set<TrackerRecord> = []) {
        self.categories = categories
        self.records = records
    }
    
    func getRecords(date: Date) -> [TrackerRecord] {
        var thisDayRecords: [TrackerRecord] = []
        for record in records {
            if Calendar.current.isDate(record.date, inSameDayAs: date) {
                thisDayRecords.append(record)
            }
        }
        
        return thisDayRecords
    }
    
    func getRecords(for id: UUID) -> [TrackerRecord] {
        var foundRecords: [TrackerRecord] = []
        for record in records {
            if record.trackerID == id {
                foundRecords.append(record)
            }
        }
        return foundRecords
    }
    
    func addRecord(_ record: TrackerRecord) {
        records.insert(record)
    }
    
    func removeRecord(_ record: TrackerRecord) {
        let calendar = Calendar.current
        let newRecords = records.filter { !calendar.isDate($0.date, inSameDayAs: record.date)}
        records = newRecords
    }
    
    func getAllCategories() -> [TrackerCategory] {
        return Array(categories)
    }
    
    func addCategory(_ newCategory: TrackerCategory) {
        let sameCategory = categories.filter {
            $0.name == newCategory.name
        }
        
        if sameCategory.isEmpty {
            categories.insert(newCategory)
        } else {
            guard let oldCategory = sameCategory.first else { return }
            var allTrackers = newCategory.trackers
            allTrackers.append(contentsOf: oldCategory.trackers)
            let updatedCategory = TrackerCategory(name: newCategory.name, trackers: allTrackers)
            categories.remove(oldCategory)
            categories.insert(updatedCategory)
        }
    }
    
    func removeCategory(_ category: TrackerCategory) {
        categories.remove(category)
    }
}

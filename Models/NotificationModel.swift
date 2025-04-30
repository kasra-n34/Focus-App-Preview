//
//  NotificationModel.swift
//  Focus
//
//  Created by Adam on 2024-07-22.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var days: [String]
    var time: Date

    init(days: [String], time: Date) {
        self.id = UUID().uuidString
        self.days = days
        self.time = time
    }

    init?(dictionary: [String: Any]) {
        guard let days = dictionary["days"] as? [String],
              let timestamp = dictionary["time"] as? Timestamp else {
            return nil
        }
        self.id = UUID().uuidString
        self.days = days
        self.time = timestamp.dateValue()
    }

    func toDictionary() -> [String: Any] {
        return [
            "days": days,
            "time": Timestamp(date: time)
        ]
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}


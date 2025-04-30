import Foundation
import FirebaseFirestoreSwift

struct ProfessionObjective: Identifiable, Codable, Equatable {
    var id: String?
    var title: String
    var description: String
    var time: Date?
    var userID: String
    var checkOffTime: Date?
    var creationTime: Date?
    var category: String? // New category field
}

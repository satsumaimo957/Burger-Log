import Foundation

struct Burger: Identifiable, Codable {
    let id = UUID()
    let pattyCount: Int
    let startDate: Date
    let endDate: Date
}

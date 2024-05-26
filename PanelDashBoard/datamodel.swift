import Foundation

// MARK: - Welcome
struct datamodel: Codable {
    let result: cancelresult
}

struct cancelresult: Codable {
    let status: String
    let index : String
    
  
}

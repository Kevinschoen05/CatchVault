//
//  LegacyPayload.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/2/26.
//
import Foundation

/// Defines the historic flat data contract exported from the production MongoDB database.
/// Acts as the input layer to the Anti-Corruption Layer (ACL).
struct LegacyPayload: Decodable {
    struct LegacyID: Decodable {
        let oid: String
        
        enum CodingKeys: String, CodingKey {
            case oid = "$oid"
        }
    }
    
    struct LegacyDate: Decodable {
        let dateString: String
        
        enum CodingKeys: String, CodingKey {
            case dateString = "$date"
        }
    }
    
    enum WeightContainer: Decodable {
        case double(Double)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let doubleValue = try? container.decode(Double.self) {
                self = .double(doubleValue)
                return
            }
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
                return
            }
            throw DecodingError.typeMismatch(
                WeightContainer.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Weight is neither a valid Double nor a String.")
            )
        }
        
        var parsedDouble: Double? {
            switch self {
            case .double(let val): return val
            case .string(let str): return Double(str.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
    
    let id: LegacyID
    let date: LegacyDate
    let species: String
    let reservoir: String
    let angler: String
    let weight: WeightContainer
    let comment: String?
    let image: String?
    let latitude: String?
    let longitude: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case date, species, reservoir, angler, weight, comment, image, latitude, longitude
    }
}

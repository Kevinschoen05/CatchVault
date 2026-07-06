import Foundation

/// Clean, standard primitive contract matching our pre-processed design-time JSON.
public struct LegacyFishRecord: Codable {
    public let id: String
    public let date: String
    public let weight: Double
    public let species: String
    public let reservoir: String
    public let angler: String
    public let image: String
    public let comment: String
    public let latitude: String
    public let longitude: String
}

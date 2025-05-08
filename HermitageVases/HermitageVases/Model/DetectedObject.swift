import UIKit
import SwiftUI

struct DetectedObject: Identifiable {
    /// Уникальный ID
    let id = UUID()
    /// Тип объекта
    let type: ImageType
    /// Процент уверенности
    let confidence: Double
    /// Bounding box
    let boundingBox: CGRect
    
    init(
        label: String,
        confidence: Double,
        boundingBox: CGRect
    ) {
        self.type = ImageType(rawValue: label) ?? .unknown
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

// MARK: - ImageType

extension DetectedObject {
    
    enum ImageType: String {
        case comos
        case dancing_getera
        case dancing_girl
        case satyr
        case unknown
    }
}

// MARK: - Calculations property

extension DetectedObject {
    
    var name: String {
        switch type {
        case .comos:
            Loc.Comos.name
        case .dancing_getera:
            Loc.DancingGetera.name
        case .dancing_girl:
            Loc.DancingGirl.name
        case .satyr:
            Loc.Satyr.name
        case .unknown:
            "unknown"
        }
    }
    
    var placement: String {
        switch type {
        case .comos:
            Loc.Comos.placement
        case .dancing_getera:
            Loc.DancingGetera.placement
        case .dancing_girl:
            Loc.DancingGirl.placement
        case .satyr:
            Loc.Satyr.placement
        case .unknown:
            "unknown"
        }
    }
    
    var description: String {
        switch type {
        case .comos:
            Loc.Comos.description
        case .dancing_getera:
            Loc.DancingGetera.description
        case .dancing_girl:
            Loc.DancingGirl.description
        case .satyr:
            Loc.Satyr.description
        case .unknown:
            "unknown"
        }
    }
    
    var boundingBoxColor: Color {
        switch type {
        case .comos: .purple
        case .dancing_getera: .red
        case .dancing_girl: .blue
        case .satyr: .yellow
        case .unknown: .black
        }
    }
    
    var imageName: String {
        switch type {
        case .comos:
            "comos"
        case .dancing_getera:
            "getera"
        case .dancing_girl:
            "girl"
        case .satyr:
            "satyr"
        case .unknown:
            "unknown"
        }
    }
}

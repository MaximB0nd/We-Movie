//
//  Data+Image.swift
//  We&Movie
//

import UIKit

extension Data {
    /// Create UIImage from film image bytes (PNG/JPEG from API).
    var asImage: UIImage? {
        UIImage(data: self)
    }
}

extension Array where Element == UInt8 {
    /// Convert film image bytes to UIImage.
    var asImage: UIImage? {
        let data = Data(self)
        return UIImage(data: data)
    }
}

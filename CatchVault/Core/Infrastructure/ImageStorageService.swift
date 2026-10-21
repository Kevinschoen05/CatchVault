//
//  ImageStorageService.swift
//

import UIKit

public final class ImageStorageService {
    public static let shared = ImageStorageService()
    private init() {}
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Compresses and writes full and thumbnail image variants to the Documents directory off the main thread.
    /// Returns the relative path string to be stored in the SwiftData model.
    public func saveCatchPhoto(_ image: UIImage) async throws -> String {
        return try await Task.detached(priority: .userInitiated) {
            let photoID = UUID().uuidString
            let relativePath = "catches/\(photoID)_full.jpg"
            let relativeThumbPath = "catches/\(photoID)_thumb.jpg"
            
            let folderURL = self.documentsDirectory.appendingPathComponent("catches", isDirectory: true)
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            
            // 1. Process and save Full-Resolution version (Max 1920px dimension)
            if let fullImage = self.resize(image, maxDimension: 1920),
               let fullData = fullImage.jpegData(compressionQuality: 0.75) {
                let fullURL = self.documentsDirectory.appendingPathComponent(relativePath)
                try fullData.write(to: fullURL, options: .atomic)
            }
            
            // 2. Process and save Thumbnail version (Max 400px dimension)
            if let thumbImage = self.resize(image, maxDimension: 400),
               let thumbData = thumbImage.jpegData(compressionQuality: 0.6) {
                let thumbURL = self.documentsDirectory.appendingPathComponent(relativeThumbPath)
                try thumbData.write(to: thumbURL, options: .atomic)
            }
            
            return relativePath
        }.value
    }
    
    /// Utility to downsample UIImage maintaining aspect ratio.
    private func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }
        
        let ratio = maxDimension / maxSide
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Loads a UIImage from a relative path string stored in SwiftData.
    public func loadImage(relativePath: String) -> UIImage? {
        let fullURL = documentsDirectory.appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: fullURL.path)
    }
    
    /// Returns the corresponding thumbnail path from a full image relative path.
    public func thumbnailPath(for relativePath: String) -> String {
        relativePath.replacingOccurrences(of: "_full.jpg", with: "_thumb.jpg")
    }
}

import Foundation
import AppKit

public actor ImageCacheActor {
    public static let shared = ImageCacheActor()
    
    private let memoryCache = NSCache<NSString, NSImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    
    public init() {
        memoryCache.totalCostLimit = 150 * 1024 * 1024 // 150 MB memory limit
        
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cachesDirectory.appendingPathComponent("Macnotix/Logos", isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    public func image(for url: URL, targetSize: CGSize? = nil) async -> NSImage? {
        let key = url.absoluteString as NSString
        
        // 1. Check Memory Cache
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }
        
        // 2. Check Disk Cache
        let diskURL = diskFilePath(for: url)
        if let diskData = try? Data(contentsOf: diskURL),
           let diskImage = NSImage(data: diskData) {
            memoryCache.setObject(diskImage, forKey: key, cost: diskData.count)
            return diskImage
        }
        
        // 3. Download over network
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10.0
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let image = NSImage(data: data) else {
                return nil
            }
            
            // Downsample if needed
            let finalImage = targetSize != nil ? resizeImage(image, targetSize: targetSize!) : image
            
            // Save to disk & memory
            try? data.write(to: diskURL)
            memoryCache.setObject(finalImage, forKey: key, cost: data.count)
            
            return finalImage
        } catch {
            return nil
        }
    }
    
    private func diskFilePath(for url: URL) -> URL {
        let hash = String(url.absoluteString.hashValue)
        return diskCacheURL.appendingPathComponent("logo_\(hash).img")
    }
    
    private func resizeImage(_ image: NSImage, targetSize: CGSize) -> NSImage {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    
    public func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
}

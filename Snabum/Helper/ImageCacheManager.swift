//
//  ImageCasher.swift
//  Snabum
//
//  Created by mac on 24/10/2025.
//

// MARK: - ImageCacheManager

import UIKit
import SDWebImage

class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    // Memory cache (fast, limited size)
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // Disk cache (persistent, larger)
    private let diskCache = SDImageCache.shared
    
    private init() {
        // Configure memory cache limits
        memoryCache.totalCostLimit = 500 * 1024 * 1024  // 500 MB
        memoryCache.countLimit = 100  // Max 100 images in memory
    }
    
    // MARK: - Get Image (Memory → Disk → Network)
    func image(for url: URL,
               completion: @escaping (UIImage?) -> Void) {
        
        let urlString = url.absoluteString as NSString
        
        // 1. Check memory cache first (fastest)
        if let cachedImage = memoryCache.object(forKey: urlString) {
            completion(cachedImage)
            return
        }
        
        // 2. Check disk cache (SDWebImage)
        diskCache.queryImage(forKey: urlString as String, options: .queryMemoryData, context: nil) { image, _,arg  in
            if let image = image {
                // Found in disk, add to memory cache
                self.memoryCache.setObject(image, forKey: urlString, cost: self.estimatedCost(image))
                completion(image)
                return
            }
            
            // 3. Download from network (SDWebImage handles it)
            SDWebImageManager.shared.loadImage(
                with: url,
                options: .retryFailed,
                progress: nil
            ) { downloadedImage, _, _, _, _, _ in
                if let downloadedImage = downloadedImage {
                    // Cache in both memory and disk
                    self.memoryCache.setObject(downloadedImage, forKey: urlString, cost: self.estimatedCost(downloadedImage))
                    // SDWebImage auto-saves to disk
                }
                completion(downloadedImage)
            }
        }
    }
    
    // MARK: - Estimate memory cost of image
    private func estimatedCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 1 }
        return cgImage.bytesPerRow * cgImage.height
    }
    
    // MARK: - Clear Caches
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearDiskCache(completion: @escaping () -> Void) {
        diskCache.clearDisk(onCompletion: completion)
    }
    
    func clearAll(completion: @escaping () -> Void) {
        clearMemoryCache()
        clearDiskCache(completion: completion)
    }
    
    // MARK: - Cache Size Info
    func cacheSize(completion: @escaping (Int) -> Void) {
       
        completion(Int(diskCache.totalDiskSize()))
    }
}

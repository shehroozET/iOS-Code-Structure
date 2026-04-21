//
//  VideoThumbnailGenerator.swift
//  Snabum
//
//  Created by mac on 10/04/2026.
//

import AVFoundation
import UIKit

class VideoThumbnailGenerator {
    
//    static func generateThumbnail(from videoURL: URL,
//                                   at time: CMTime = .zero,
//                                   completion: @escaping (UIImage?) -> Void) {
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let asset = AVAsset(url: videoURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
//            generator.maximumSize = CGSize(width: 400, height: 400)
//            
//            do {
//                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
//                DispatchQueue.main.async {
//                    completion(thumbnail)
//                }
//            } catch {
//                AppLogger.debug.error("Thumbnail generation failed: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }
//    }
//    
//    /// Generate thumbnail from remote video URL (downloads first)
//    static func generateThumbnailFromRemote(videoURL: URL,
//                                             completion: @escaping (UIImage?) -> Void) {
//        let task = URLSession.shared.downloadTask(with: videoURL) { localURL, _, error in
//            guard let localURL = localURL, error == nil else {
//                completion(nil)
//                return
//            }
//            
//            generateThumbnail(from: localURL, at: .zero) { thumbnail in
//                // Clean up temp file
//                try? FileManager.default.removeItem(at: localURL)
//                completion(thumbnail)
//            }
//        }
//        task.resume()
//    }
//    
    static func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail error:", error)
            return nil
        }
    }
}

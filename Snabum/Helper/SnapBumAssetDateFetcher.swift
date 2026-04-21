//
//  DateFetcher.swift
//  Snabum
//
//  Created by mac on 25/02/2026.
//
import Photos
import PhotosUI
import AVFoundation
import ImageIO
import UniformTypeIdentifiers


final class SnapBumAssetDateFetcher {
    
    static let shared = SnapBumAssetDateFetcher()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        f.timeZone = .current
        return f
    }()
    
    private init() {}
    
    func fetchDate(from result: PHPickerResult, completion: @escaping (String) -> Void) {
        guard let assetId = result.assetIdentifier else {
            fetchDateFromItemProvider(result, completion: completion)
            return
        }
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        
        if let asset = fetchResult.firstObject, let date = asset.creationDate {
            completion(isoFormatter.string(from: date)) // Local timezone
            return
        }
        
        if let asset = fetchResult.firstObject {
            fetchDateFromPHAssetMetadata(asset, completion: completion)
        } else {
            fetchDateFromItemProvider(result, completion: completion)
        }
    }
}

// MARK: - Private Helpers
private extension SnapBumAssetDateFetcher {
    
    func fetchDateFromPHAssetMetadata(_ asset: PHAsset, completion: @escaping (String) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        
        asset.requestContentEditingInput(with: options) { input, _ in
            guard let url = input?.fullSizeImageURL else {
                completion(self.currentDate())
                return
            }
            
            if let date = self.extractDateFromImageURL(url) {
                completion(self.isoFormatter.string(from: date))
            } else {
                completion(self.currentDate())
            }
        }
    }
    
    private func fetchDateFromItemProvider(_ result: PHPickerResult, completion: @escaping (String) -> Void) {
            let provider = result.itemProvider
            
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                fetchVideoDate(from: provider, completion: completion)
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                    guard let url else {
                        completion(self.currentDate())
                        return
                    }
                    
                    if let date = self.extractDateFromImageURL(url) {
                        completion(self.isoFormatter.string(from: date))
                    } else {
                        completion(self.currentDate())
                    }
                }
                return
            }
            
            completion(currentDate())
        }
    
    // MARK: - Image Metadata
    func extractDateFromImageURL(_ url: URL) -> Date? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let exif = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
              let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: dateString)
    }
    

   

    func fetchVideoDate(from itemProvider: NSItemProvider, completion: @escaping (String) -> Void) {
        guard itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else {
            completion(currentDate())
            return
        }

        // 1️⃣ Load the video from the itemProvider
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { tempURL, error in
            guard let tempURL else {
                completion(self.currentDate())
                return
            }

            // 2️⃣ Copy immediately to a safe temporary location
            let safeURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            do {
                try FileManager.default.copyItem(at: tempURL, to: safeURL)
            } catch {
                print("Failed to copy video:", error)
                completion(self.currentDate())
                return
            }

            // 3️⃣ Use the copied file to extract metadata
            Task {
                if let date = await self.extractVideoDate(from: safeURL) {
                    completion(self.isoFormatter.string(from: date))
                } else {
                    completion(self.currentDate())
                }

                // Optional: clean up the temp copy after processing
                try? FileManager.default.removeItem(at: safeURL)
            }
        }
    }

    // ✅ Only read metadata, no copy inside
    func extractVideoDate(from url: URL) async -> Date? {
        let asset = AVURLAsset(url: url)

        // 1️⃣ Try common metadata
        do {
            let commonMetadata: [AVMetadataItem] = try await asset.load(.commonMetadata)
            if let date = await dateFrom(metadataItems: commonMetadata) { return date }
        } catch {
            print("Common metadata failed:", error)
        }

        // 2️⃣ Try QuickTime metadata
        do {
            let qtMetadata = try await asset.loadMetadata(for: .quickTimeMetadata)
            if let date = await dateFrom(metadataItems: qtMetadata) { return date }
        } catch {
            print("QuickTime metadata failed:", error) }

        // 3️⃣ Fallback: file creation date
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
           let creationDate = attrs[.creationDate] as? Date {
            return creationDate
        }

        return nil
    }

    func dateFrom(metadataItems: [AVMetadataItem]) async -> Date? {
        for item in metadataItems {
            if item.commonKey?.rawValue == "creationDate" {
                if let str = try? await item.load(.stringValue),
                   let date = ISO8601DateFormatter().date(from: str) {
                    return date
                }
            }
        }
        return nil
    }






    func currentDate() -> String {
        return isoFormatter.string(from: Date())
    }
}


//final class SnapBumAssetDateFetcher {
//    
//    static let shared = SnapBumAssetDateFetcher()
//    
//    private let isoFormatter: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [
//            .withInternetDateTime,
//            .withTimeZone
//        ]
//        
//        f.timeZone = TimeZone.current
//        return f
//    }()
//    
//    private init() {}
//    
//    // MAIN ENTRY POINT
//    func fetchDate(
//        from result: PHPickerResult,
//        completion: @escaping (String) -> Void
//    ) {
//        
//        guard let assetId = result.assetIdentifier else {
//            fetchDateFromItemProvider(result, completion: completion)
//            return
//        }
//        
//        let fetchResult = PHAsset.fetchAssets(
//            withLocalIdentifiers: [assetId],
//            options: nil
//        )
//        
//        guard let asset = fetchResult.firstObject else {
//            fetchDateFromItemProvider(result, completion: completion)
//            return
//        }
//        
//        // BEST CASE
//        if let date = asset.creationDate {
//            print(date)
//            completion(isoFormatter.string(from: date))
//            return
//        }
//        
//        // FALLBACK → METADATA EXTRACTION
//        fetchDateFromPHAssetMetadata(asset, completion: completion)
//    }
//}
//
//private extension SnapBumAssetDateFetcher {
//    
//    func fetchDateFromPHAssetMetadata(
//        _ asset: PHAsset,
//        completion: @escaping (String) -> Void
//    ) {
//        
//        let options = PHContentEditingInputRequestOptions()
//        options.isNetworkAccessAllowed = true
//        
//        asset.requestContentEditingInput(with: options) {
//            input, _ in
//            
//            guard let url = input?.fullSizeImageURL else {
//                completion(self.currentDate())
//                return
//            }
//            
//            if let date = self.extractDateFromImageURL(url) {
//                print(date)
//                completion(self.isoFormatter.string(from: date))
//                return
//            }
//            
//            completion(self.currentDate())
//        }
//    }
//    
//    func fetchDateFromItemProvider(
//        _ result: PHPickerResult,
//        completion: @escaping (String) -> Void
//    ) {
//        
//        if result.itemProvider.hasItemConformingToTypeIdentifier(
//            UTType.movie.identifier
//        ) {
//            
//            result.itemProvider.loadFileRepresentation(
//                forTypeIdentifier: UTType.movie.identifier
//            ) { url, _ in
//                
//                guard let url else {
//                    completion(self.currentDate())
//                    return
//                }
//                
//                if let date = self.extractDateFromVideoURL(url) {
//                    print(date)
//                    completion(self.isoFormatter.string(from: date))
//                } else {
//                    completion(self.currentDate())
//                }
//            }
//            
//            return
//        }
//        
//        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//            
//            result.itemProvider.loadFileRepresentation(
//                forTypeIdentifier: UTType.image.identifier
//            ) { url, _ in
//                
//                guard let url else {
//                    completion(self.currentDate())
//                    return
//                }
//                
//                if let date = self.extractDateFromImageURL(url) {
//                    print(date)
//                    completion(self.isoFormatter.string(from: date))
//                } else {
//                    completion(self.currentDate())
//                }
//            }
//            
//            return
//        }
//        
//        completion(self.currentDate())
//    }
//}
//
//private extension SnapBumAssetDateFetcher {
//    
//    func extractDateFromImageURL(_ url: URL) -> Date? {
//        
//        guard let source = CGImageSourceCreateWithURL(
//            url as CFURL,
//            nil
//        ) else { return nil }
//        
//        guard let metadata =
//                CGImageSourceCopyPropertiesAtIndex(
//                    source,
//                    0,
//                    nil
//                ) as? [CFString: Any] else { return nil }
//        
//        if let exif =
//            metadata[kCGImagePropertyExifDictionary]
//            as? [CFString: Any],
//           let dateString =
//            exif[kCGImagePropertyExifDateTimeOriginal]
//            as? String {
//            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
//            formatter.timeZone = TimeZone(identifier: "UTC")
//            return formatter.date(from: dateString)
//        }
//        
//        return nil
//    }
//    
//    func extractDateFromVideoURL(_ url: URL) -> Date? {
//        
//        let asset = AVURLAsset(url: url)
//        
//        // 1. Try common metadata
//        if let date = extractDate(from: asset.commonMetadata) {
//            return date
//        }
//        
//        // 2. Try QuickTime metadata (MOST IMPORTANT for iPhone videos)
//        if let date = extractDate(from: asset.metadata(forFormat: .quickTimeMetadata)) {
//            return date
//        }
//        
//        // 3. Try metadata from tracks
//        for track in asset.tracks {
//            if let date = extractDate(from: track.metadata) {
//                return date
//            }
//        }
//        
//        // 4. Try file system creation date (last fallback)
//        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
//           let creationDate = attributes[.creationDate] as? Date {
//            return creationDate
//        }
//        
//        return nil
//    }
//    private func extractDate(from metadata: [AVMetadataItem]) -> Date? {
//        
//        for item in metadata {
//            
//            // QuickTime creation date
//            if item.identifier?.rawValue == "mdta/com.apple.quicktime.creationdate" ||
//               item.commonKey?.rawValue == "creationDate" {
//                
//                if let value = item.stringValue {
//                    
//                    // Try ISO8601 first
//                    if let date = ISO8601DateFormatter().date(from: value) {
//                        return date
//                    }
//                    
//                    // Try QuickTime format
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//                    formatter.timeZone = TimeZone.current
//                    
//                    if let date = formatter.date(from: value) {
//                        return date
//                    }
//                }
//            }
//        }
//        
//        return nil
//    }
//    func currentDate() -> String {
//        return isoFormatter.string(from: Date())
//    }
//}

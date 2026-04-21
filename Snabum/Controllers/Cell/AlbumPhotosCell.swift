//
//  AlbumPhotosCell.swift
//  Snabum
//
//  Created by mac on 22/10/2025.
//

import UIKit
import SDWebImage
import AVFoundation

// MARK: - Public Access

extension AlbumPhotosCell {
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
}

final class AlbumPhotosCell: UICollectionViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageContainerView: UIView!

    // MARK: - Properties
    
    private var shimmerView: ShimmerView!
    private var reloadButton: UIButton!
    
    private var currentImageURL: URL?
    private var mediaType: MediaType?

    private let playButton: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        imageView.image = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupShimmer()
        setupReloadButton()
        setupPlayButton()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }

}

// MARK: - UI Setup

private extension AlbumPhotosCell {

    func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
    }

    func setupShimmer() {
        shimmerView = ShimmerView(frame: imageView.bounds)
        shimmerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shimmerView.layer.cornerRadius = 15
        shimmerView.clipsToBounds = true
        imageView.addSubview(shimmerView)
    }

    func setupReloadButton() {
        reloadButton = UIButton(type: .system)
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.tintColor = .white
        reloadButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        reloadButton.layer.cornerRadius = 20
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.isHidden = true
        
        reloadButton.addTarget(
            self,
            action: #selector(reloadImageTapped),
            for: .touchUpInside
        )
        
        contentView.addSubview(reloadButton)

        NSLayoutConstraint.activate([
            reloadButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            reloadButton.widthAnchor.constraint(equalToConstant: 40),
            reloadButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func setupPlayButton() {
        contentView.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - Configuration

extension AlbumPhotosCell {

    func configure(with url: URL, type: MediaType) {
        
        currentImageURL = url
        mediaType = type
        
        resetUIForLoading()
        
        let cacheKey = makeCacheKey(from: url)
        let diskCache = SDImageCache.shared
        
        switch type {
        case .photo:
            loadPhoto(url: url, cacheKey: cacheKey, cache: diskCache)
            
        case .video:
            loadVideoThumbnail(url: url, cacheKey: cacheKey, cache: diskCache)
        }
    }
}

// MARK: - Photo Loading

private extension AlbumPhotosCell {

    func loadPhoto(
        url: URL,
        cacheKey: String,
        cache: SDImageCache
    ) {
        cache.queryImage(
            forKey: cacheKey,
            options: .queryMemoryData,
            context: nil
        ) { [weak self] cachedImage, _, _ in
            
            guard let self = self else { return }
            guard self.isCellValid(for: url, type: .photo) else { return }
            
            if let cachedImage = cachedImage {
                self.displayImage(cachedImage, isVideo: false)
            } else {
                self.loadPhotoFromNetwork(
                    url: url,
                    cacheKey: cacheKey,
                    cache: cache
                )
            }
        }
    }

    func loadPhotoFromNetwork(
        url: URL,
        cacheKey: String,
        cache: SDImageCache
    ) {
        ImageCacheManager.shared.image(for: url) { [weak self] image in
            
            guard let self = self else { return }
            guard self.isCellValid(for: url, type: .photo) else { return }
            
            DispatchQueue.main.async {
                self.stopShimmer()
                
                if let image = image {
                    self.displayImage(image, isVideo: false)
                    cache.store(image, forKey: cacheKey)
                } else {
                    self.showErrorState()
                }
            }
        }
    }
}

// MARK: - Video Loading

private extension AlbumPhotosCell {

    func loadVideoThumbnail(
        url: URL,
        cacheKey: String,
        cache: SDImageCache
    ) {
        cache.queryImage(
            forKey: cacheKey,
            options: .queryMemoryData,
            context: nil
        ) { [weak self] cachedThumbnail, _, _ in
            
            guard let self = self else { return }
            guard self.isCellValid(for: url, type: .video) else { return }
            
            if let cachedThumbnail = cachedThumbnail {
                self.displayImage(cachedThumbnail, isVideo: true)
            } else {
                self.generateVideoThumbnail(
                    url: url,
                    cacheKey: cacheKey,
                    cache: cache
                )
            }
        }
    }

    func generateVideoThumbnail(
        url: URL,
        cacheKey: String,
        cache: SDImageCache
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self = self else { return }
            
            let thumbnail = self.generateThumbnail(from: url)
            
            DispatchQueue.main.async {
                guard self.isCellValid(for: url, type: .video) else { return }
                
                self.stopShimmer()
                
                if let thumbnail = thumbnail {
                    self.displayImage(thumbnail, isVideo: true)
                    cache.store(thumbnail, forKey: cacheKey)
                } else {
                    self.showErrorState()
                }
            }
        }
    }
}

// MARK: - UI State

private extension AlbumPhotosCell {

    func resetUIForLoading() {
        startShimmer()
        imageView.image = nil
        reloadButton.isHidden = true
        playButton.isHidden = true
    }

    func displayImage(_ image: UIImage, isVideo: Bool) {
        stopShimmer()
        imageView.image = image
        reloadButton.isHidden = true
        playButton.isHidden = !isVideo
    }

    func showErrorState() {
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        reloadButton.isHidden = false
        playButton.isHidden = true
    }
}

// MARK: - Helpers

private extension AlbumPhotosCell {

    func makeCacheKey(from url: URL) -> String {
        return "media_\(url.lastPathComponent)"
    }

    func isCellValid(for url: URL, type: MediaType) -> Bool {
        return currentImageURL == url && mediaType == type
    }

    func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 500, height: 500)
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail error:", error)
            return nil
        }
    }

    func resetCell() {
        currentImageURL = nil
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        stopShimmer()
        reloadButton.isHidden = true
        playButton.isHidden = true
    }
}

// MARK: - Actions

private extension AlbumPhotosCell {

    @objc func reloadImageTapped() {
        guard let url = currentImageURL,
              let type = mediaType else { return }
        
        configure(with: url, type: type)
    }
}

// MARK: - Loader

private extension AlbumPhotosCell {

    func startShimmer() {
        shimmerView.isHidden = false
        shimmerView.startShimmer()
        reloadButton.isHidden = true
    }

    func stopShimmer() {
        shimmerView.stopShimmer()
        shimmerView.isHidden = true
    }
}

// MARK: - Public

extension AlbumPhotosCell {

    func updateImageSize(_ size: CGFloat) {
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageContainerView.widthAnchor.constraint(equalToConstant: size),
            imageContainerView.heightAnchor.constraint(equalToConstant: size)
        ])
    }
}

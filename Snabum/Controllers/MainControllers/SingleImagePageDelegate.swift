//
//  SingleImagePageDelegate.swift
//  Snabum
//
//  Created by mac on 07/04/2026.
//


import UIKit
import AVKit
import SDWebImage
import ProgressHUD


protocol SingleImagePageDelegate: AnyObject {
    func didRequestDelete(mediaID: Int, pageIndex: Int)
    func didRequestShare(image: UIImage)
    func didRequestSave(image: UIImage)
    func didRequestShareVideo(url: URL)
    func didRequestSaveVideo(url: URL)
    func didRequestPlayVideo(url: URL)
}

extension SingleImagePageDelegate {
    func didRequestShareVideo(url: URL) {}
    func didRequestSaveVideo(url: URL) {}
    func didRequestPlayVideo(url: URL) {}
}

class SingleImagePageViewController: UIViewController {

    // MARK: - Public Input
    var item: MediaItem!
    var pageIndex: Int = 0
    var canUserEdit: Bool = true
    weak var pageDelegate: SingleImagePageDelegate?

    // MARK: - Private — Image
    private let scrollView   = UIScrollView()
    private let imageView    = UIImageView()

    // MARK: - Private — Video Overlay
    private let playButton   = UIButton(type: .system)
    private let videoBadge   = UILabel()
    
    // MARK: - Loading indicator
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupLoadingIndicator()
        loadContent()
        setupDoubleTapToZoom()
    }

    // MARK: - Scroll View + Image Setup
    private func setupScrollView() {
        scrollView.frame                          = view.bounds
        scrollView.autoresizingMask               = [.flexibleWidth, .flexibleHeight]
        scrollView.minimumZoomScale               = 1.0
        scrollView.maximumZoomScale               = 4.0
        scrollView.delegate                       = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator   = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.zoomScale                      = 1.0
        view.addSubview(scrollView)

        imageView.contentMode                     = .scaleAspectFit
        imageView.clipsToBounds                   = true
        imageView.backgroundColor                 = .black
        scrollView.addSubview(imageView)
    }
    
    // MARK: - Loading Indicator
    private func setupLoadingIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Load Content (Image or Video)
    private func loadContent() {
        if item.mediaType == .video {
            loadVideoThumbnail()
        } else {
            loadImage()
        }
    }

    // MARK: - Load Image with Cache
    private func loadImage() {
       
       
        guard let url = URL(string: item.imageURL) else { return }
        let cacheKey = "media_\(url.lastPathComponent)"
        let diskCache = SDImageCache.shared
        // Check cache first
        diskCache.queryImage(
            forKey: cacheKey,
            options: .queryMemoryData,
            context: nil
        ) { [weak self] cachedImage, _, _ in

            guard let self = self else { return }
           
            if let cachedImage = cachedImage {
                
                print("Loaded photo from cache: \(cacheKey)")

                DispatchQueue.main.async {
                  self.activityIndicator.stopAnimating()
                    self.imageView.image = cachedImage ?? UIImage(systemName: "photo")
                    self.layoutImageView()
                   
                }

            } else {

                print("Photo not in cache. Loading from network...")

                ImageCacheManager.shared.image(for: url) { [weak self] image in
                    guard let self = self else { return }

                   

                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()

                        if let image = image {

                            print("Caching photo: \(cacheKey)")
                            self.imageView.image = image
                           
                            self.layoutImageView()

                            // Store in cache
                            diskCache.store(image, forKey: cacheKey)

                        } else {

                            self.imageView.image = cachedImage ?? UIImage(systemName: "photo")
                            self.layoutImageView()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Load Video Thumbnail with Cache
    private func loadVideoThumbnail() {
        guard let videoURLString = item.videoURL,
              let videoURL = URL(string: videoURLString) else {
            loadImage()
            return
        }
        
        activityIndicator.startAnimating()
        
        // Check if thumbnail already cached
        let cacheKey = "media_\(videoURL.lastPathComponent)"
        let diskCache = SDImageCache.shared
        
        diskCache.queryImage(forKey: cacheKey as String, options: .queryMemoryData, context: nil) { [weak self] cachedThumbnail, _,_  in
            if let cachedThumbnail = cachedThumbnail {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = cachedThumbnail
                    self?.layoutImageView()
                    self?.setupVideoOverlay()
                }
                return
            }
            
            // Generate thumbnail if not cached
            let thumbnail = VideoThumbnailGenerator.generateThumbnail(from: videoURL)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let thumbnail = thumbnail {
                    diskCache.store(thumbnail, forKey: cacheKey as String)
                    self?.imageView.image = thumbnail
                } else {
                    self?.loadImage()
                    return
                }
                
                self?.layoutImageView()
                self?.setupVideoOverlay()
            }
            
        }
    }

    // MARK: - Layout Image View
    private func layoutImageView() {
        guard let image = imageView.image else { return }

        let scrollViewSize = scrollView.bounds.size
        let imageSize      = image.size

        let imageAspectRatio  = imageSize.width / imageSize.height
        let scrollAspectRatio = scrollViewSize.width / scrollViewSize.height

        var frame = CGRect.zero

        if imageAspectRatio > scrollAspectRatio {
            frame.size.width  = scrollViewSize.width
            frame.size.height = scrollViewSize.width / imageAspectRatio
        } else {
            frame.size.height = scrollViewSize.height
            frame.size.width  = scrollViewSize.height * imageAspectRatio
        }

        frame.origin.x = (scrollViewSize.width  - frame.size.width)  / 2
        frame.origin.y = (scrollViewSize.height - frame.size.height) / 2

        imageView.frame = frame
        scrollView.contentSize = frame.size
        scrollView.zoomScale = 1.0
    }

    // MARK: - Video Overlay
    private func setupVideoOverlay() {
        playButton.translatesAutoresizingMaskIntoConstraints = false

        let playConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: .normal)
        playButton.tintColor = .white

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView   = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius       = 35
        blurView.clipsToBounds            = true

        view.addSubview(blurView)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 70),
            blurView.heightAnchor.constraint(equalToConstant: 70),

            playButton.centerXAnchor.constraint(equalTo: blurView.centerXAnchor, constant: 3),
            playButton.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 70),
            playButton.heightAnchor.constraint(equalToConstant: 70),
        ])

        playButton.addTarget(self, action: #selector(playVideoTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonPressDown), for: .touchDown)
        playButton.addTarget(self, action: #selector(playButtonPressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        setupVideoBadge()
    }

    private func setupVideoBadge() {
        videoBadge.translatesAutoresizingMaskIntoConstraints = false
        videoBadge.text          = "VIDEO"
        videoBadge.textColor     = .white
        videoBadge.font          = UIFont.systemFont(ofSize: 11, weight: .bold)
        videoBadge.textAlignment = .center

        let blurEffect  = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let badgeBlur   = UIVisualEffectView(effect: blurEffect)
        badgeBlur.translatesAutoresizingMaskIntoConstraints = false
        badgeBlur.layer.cornerRadius = 10
        badgeBlur.clipsToBounds      = true

        view.addSubview(badgeBlur)
        badgeBlur.contentView.addSubview(videoBadge)

        NSLayoutConstraint.activate([
            badgeBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            badgeBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            badgeBlur.heightAnchor.constraint(equalToConstant: 22),

            videoBadge.leadingAnchor.constraint(equalTo: badgeBlur.contentView.leadingAnchor, constant: 8),
            videoBadge.trailingAnchor.constraint(equalTo: badgeBlur.contentView.trailingAnchor, constant: -8),
            videoBadge.centerYAnchor.constraint(equalTo: badgeBlur.contentView.centerYAnchor),
        ])
    }

    // MARK: - Play Button Actions
    @objc private func playVideoTapped() {
        guard let videoURLString = item.videoURL,
              let videoURL = URL(string: videoURLString) else {
            return
        }
        pageDelegate?.didRequestPlayVideo(url: videoURL)
    }

    @objc private func playButtonPressDown() {
        UIView.animate(withDuration: 0.1) {
            self.playButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }
    }

    @objc private func playButtonPressUp() {
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6) {
            self.playButton.transform = .identity
        }
    }

    // MARK: - Double Tap to Zoom
    private func setupDoubleTapToZoom() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        
        if item.mediaType == .photo {
            scrollView.addGestureRecognizer(tap)
        }
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let zoomRect = CGRect(
                x: point.x - 50,
                y: point.y - 50,
                width: 100,
                height: 100
            )
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }

    // MARK: - Public Helpers
    func currentImage() -> UIImage? { imageView.image }

    func currentVideoURL() -> URL? {
        guard let urlString = item.videoURL else { return nil }
        return URL(string: urlString)
    }

    func resetZoom() {
        scrollView.setZoomScale(1.0, animated: false)
    }

    var isZoomed: Bool { scrollView.zoomScale > 1.0 }
}

// MARK: - UIScrollViewDelegate
extension SingleImagePageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        item.mediaType == .photo ? imageView : nil
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }

    private func centerImageInScrollView() {
        let offsetX = max((scrollView.bounds.width  - scrollView.contentSize.width)  * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        imageView.center = CGPoint(
            x: scrollView.contentSize.width  * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
}

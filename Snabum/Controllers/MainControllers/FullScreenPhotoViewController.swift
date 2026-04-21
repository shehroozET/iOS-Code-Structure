//
//  FullScreenPhotoViewController.swift
//  Snabum
//
//  Created by mac on 23/10/2025.
//

// FullImageViewController.swift
import UIKit
import AVKit
import Photos
import ProgressHUD


struct MediaItem {
    let imageURL: String
    let videoURL: String?
    let mediaID: Int
    let date: String?
    let mediaType: MediaType
}


class FullImageViewController: UIViewController {

    // MARK: - Public Input
    var items: [MediaItem] = []
    var startIndex: Int = 0
    var isFromSharedFolder: Bool = false
    var canUserEdit: Bool = true
    var onDismiss: ((Bool) -> Void)?

    // MARK: - Private
    private var pageVC: UIPageViewController!
    private var currentIndex: Int = 0

    private let closeButton   = UIButton(type: .system)
    private let shareButton   = UIButton(type: .system)
    private let saveButton    = UIButton(type: .system)
    private let deleteButton  = UIButton(type: .system)
    private let dateLabel     = UILabel()
    private let pageLabel     = UILabel()
    private var buttonStack: UIStackView!

    // MARK: - Computed helper
    private var currentItem: MediaItem? {
        guard items.indices.contains(currentIndex) else { return nil }
        return items[currentIndex]
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        currentIndex = startIndex

        setupPageViewController()
        setupOverlayUI()
        updateOverlay(for: currentIndex)
    }

    // MARK: - Page View Controller Setup
    private func setupPageViewController() {
        pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 20]
        )
        pageVC.dataSource = self
        pageVC.delegate   = self

        addChild(pageVC)
        pageVC.view.frame = view.bounds
        pageVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)

        if let initial = makePage(at: startIndex) {
            pageVC.setViewControllers([initial], direction: .forward, animated: false)
        }
    }

    private func makePage(at index: Int) -> SingleImagePageViewController? {
        guard index >= 0, index < items.count else { return nil }
        let vc = SingleImagePageViewController()
        vc.item         = items[index]
        vc.pageIndex    = index
        vc.canUserEdit  = canUserEdit
        vc.pageDelegate = self
        return vc
    }

    // MARK: - Overlay UI
    private func setupOverlayUI() {
        setupCloseButton()
        setupDateLabel()
        setupPageLabel()
        setupButtons()
    }

    private func setupCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor(named: "AppMainColor")
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

    private func setupDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 60),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -10)
        ])
    }

    private func setupPageLabel() {
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        pageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        pageLabel.textAlignment = .center
        view.addSubview(pageLabel)

        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupButtons() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)

        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: config), for: .normal)
        saveButton.setImage(UIImage(systemName: "arrow.down.circle",    withConfiguration: config), for: .normal)
        deleteButton.setImage(UIImage(systemName: "trash",              withConfiguration: config), for: .normal)

        shareButton.setTitle(" Share",   for: .normal)
        saveButton.setTitle(" Save",     for: .normal)
        deleteButton.setTitle(" Delete", for: .normal)

        [shareButton, saveButton, deleteButton].forEach { btn in
            btn.tintColor = .white
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            btn.layer.cornerRadius = 25
            btn.layer.masksToBounds = true
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            btn.imageEdgeInsets   = UIEdgeInsets(top: 0,  left: -5,  bottom: 0,  right: 0)
        }

        shareButton.backgroundColor  = UIColor(named: "AppMainColor")
        saveButton.backgroundColor   = UIColor(named: "App_font_color")
        deleteButton.backgroundColor = .systemRed

        shareButton.addTarget(self,  action: #selector(shareTapped),  for: .touchUpInside)
        saveButton.addTarget(self,   action: #selector(saveTapped),   for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        buttonStack = UIStackView(arrangedSubviews: [shareButton, saveButton])
        if canUserEdit { buttonStack.addArrangedSubview(deleteButton) }
        buttonStack.axis         = .horizontal
        buttonStack.alignment    = .center
        buttonStack.spacing      = 15
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            buttonStack.widthAnchor.constraint(equalToConstant: canUserEdit ? 360 : 240)
        ])
    }

    // MARK: - Update Overlay for Current Page
    private func updateOverlay(for index: Int) {
        guard index < items.count else { return }
        let item = items[index]
        dateLabel.text = formatDate(item.date)

        if items.count > 1 {
            pageLabel.text    = "\(index + 1) / \(items.count)"
            pageLabel.isHidden = false
        } else {
            pageLabel.isHidden = true
        }

        // Update Save button icon: video uses different symbol
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let saveIcon = "arrow.down.circle"
        saveButton.setImage(UIImage(systemName: saveIcon, withConfiguration: config), for: .normal)
    }

    // MARK: - Date Formatter
    private func formatDate(_ raw: String?) -> String {
        guard let raw = raw else { return "" }
        let display = DateFormatter()
        display.dateFormat = "dd MMM yyyy • HH:mm"
        display.timeZone = TimeZone(secondsFromGMT: 0)

        let isoFull = ISO8601DateFormatter()
        isoFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFull.date(from: raw) { return display.string(from: d) }

        let isoSimple = ISO8601DateFormatter()
        isoSimple.formatOptions = [.withInternetDateTime]
        if let d = isoSimple.date(from: raw) { return display.string(from: d) }

        return raw
    }

    // MARK: - Current Page Helper
    private func currentPage() -> SingleImagePageViewController? {
        pageVC.viewControllers?.first as? SingleImagePageViewController
    }

    // MARK: - Button Actions
    @objc private func dismissView() {
        dismiss(animated: true)
    }

    @objc private func shareTapped() {
        guard let item = currentItem else { return }

        switch item.mediaType {

        case .photo:
            guard let img = currentPage()?.currentImage() else { return }
            let ac = UIActivityViewController(activityItems: [img], applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = view
            present(ac, animated: true)

        case .video:
            guard let videoURLString = item.videoURL,
                  let videoURL = URL(string: videoURLString) else { return }
            // Share the remote URL directly; system handles it
            let ac = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = view
            present(ac, animated: true)
        }
    }

    @objc private func saveTapped() {
        guard let item = currentItem else { return }

        switch item.mediaType {

        case .photo:
            guard let img = currentPage()?.currentImage() else { return }
            UIImageWriteToSavedPhotosAlbum(
                img, self,
                #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)),
                nil
            )

        case .video:
            guard let videoURLString = item.videoURL,
                  let videoURL = URL(string: videoURLString) else { return }
            saveVideoToPhotos(url: videoURL)
        }
    }

    @objc private func imageSaved(_ image: UIImage,
                                   didFinishSavingWithError error: Error?,
                                   contextInfo: UnsafeRawPointer) {
        showToastAlert(message: error == nil ? "Image saved to Photos." : (error?.localizedDescription ?? "Error"))
    }

    // MARK: - Save Video to Photos Library
    private func saveVideoToPhotos(url: URL) {
        ProgressHUD.animate("Saving video...")

        // If it's a remote URL, download first then save
        if url.scheme == "http" || url.scheme == "https" {
            downloadAndSaveVideo(remoteURL: url)
        } else {
            // Local file
            saveLocalVideoToPhotos(localURL: url)
        }
    }

    private func downloadAndSaveVideo(remoteURL: URL) {
        let task = URLSession.shared.downloadTask(with: remoteURL) { [weak self] localURL, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    ProgressHUD.dismiss()
                    self.showToastAlert(message: error.localizedDescription)
                    return
                }
                guard let localURL = localURL else { return }

                // Move to a temp location with a proper extension
                let ext       = remoteURL.pathExtension.isEmpty ? "mp4" : remoteURL.pathExtension
                let destURL   = FileManager.default.temporaryDirectory
                                    .appendingPathComponent(UUID().uuidString)
                                    .appendingPathExtension(ext)
                try? FileManager.default.moveItem(at: localURL, to: destURL)
                self.saveLocalVideoToPhotos(localURL: destURL)
            }
        }
        task.resume()
    }

    private func saveLocalVideoToPhotos(localURL: URL) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    ProgressHUD.dismiss()
                    self.showToastAlert(message: "Photos access denied. Enable it in Settings.")
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localURL)
                }) { success, error in
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        self.showToastAlert(
                            message: success ? "Video saved to Photos." : (error?.localizedDescription ?? "Error saving video.")
                        )
                    }
                }
            }
        }
    }

    @objc private func deleteTapped() {
        let mediaID = items[currentIndex].mediaID
        let isVideo = currentItem?.mediaType == .video
        let message = "Are you sure you want to delete this \(isVideo ? "video" : "image")?"

        showAlertAction(
            title: "",
            message: message,
            canShowCancel: true,
            actionConfirmationNormal: "Delete"
        ) {
            ProgressHUD.animate()
            AuthService.deleteMedia(mediaID: mediaID) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    switch result {
                    case .success:
                        AppLogger.debug.info("Deleted media ID \(mediaID)")
                        self.removeCurrentItem()

                    case .failure(let error):
                        self.showToastAlert(message: error.localizedDescription)
                        AppLogger.debug.info("Delete failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Remove Deleted Item
    private func removeCurrentItem() {
        guard items.indices.contains(currentIndex) else { return }
        let wasVideo = items[currentIndex].mediaType == .video
        items.remove(at: currentIndex)

        let successMessage = wasVideo ? "Video Deleted" : "Image Deleted"

        if items.isEmpty {
            showToastAlert(message: successMessage) {
                self.onDismiss?(true)
                self.dismiss(animated: true)
            }
            return
        }

        let nextIndex = min(currentIndex, items.count - 1)
        currentIndex  = nextIndex

        if let nextPage = makePage(at: nextIndex) {
            pageVC.setViewControllers(
                [nextPage],
                direction: .reverse,
                animated: true
            ) { [weak self] _ in
                self?.showToastAlert(message: successMessage)
                self?.onDismiss?(true)
            }
        }

        updateOverlay(for: currentIndex)
    }

    // MARK: - Present Video Player
    private func presentVideoPlayer(url: URL) {
        let player    = AVPlayer(url: url)
        let playerVC  = AVPlayerViewController()
        playerVC.player = player

        // iOS-style presentation (full screen)
        playerVC.modalPresentationStyle = .fullScreen

        present(playerVC, animated: true) {
            player.play()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension FullImageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? SingleImagePageViewController else { return nil }
        return makePage(at: page.pageIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? SingleImagePageViewController else { return nil }
        return makePage(at: page.pageIndex + 1)
    }
}

// MARK: - UIPageViewControllerDelegate
extension FullImageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let page = pageVC.viewControllers?.first as? SingleImagePageViewController
        else { return }

        currentIndex = page.pageIndex
        updateOverlay(for: currentIndex)

        previousViewControllers
            .compactMap { $0 as? SingleImagePageViewController }
            .forEach { $0.resetZoom() }
    }
}

// MARK: - SingleImagePageDelegate
extension FullImageViewController: SingleImagePageDelegate {

    func didRequestDelete(mediaID: Int, pageIndex: Int) {
        deleteTapped()
    }

    func didRequestShare(image: UIImage) {
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(ac, animated: true)
    }

    func didRequestSave(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image, self,
            #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    func didRequestShareVideo(url: URL) {
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(ac, animated: true)
    }

    func didRequestSaveVideo(url: URL) {
        saveVideoToPhotos(url: url)
    }

    // ---- NEW ----
    func didRequestPlayVideo(url: URL) {
        presentVideoPlayer(url: url)
    }
}

//
//  UploadPhotosVideosVCLib.swift
//  Snabum
//
//  Created by mac on 27/02/2026.
//

import UIKit
import DKImagePickerController
import Photos

import UIKit

struct MediaAsset {
    var image: UIImage?
    var videoURL: URL?
    var date: Date
    var isVideo: Bool
}


class UploadPhotosVideosVCLib: UIViewController {

    // MARK: - OUTLETS

    @IBOutlet weak var collectionViewUploadedFiles: UICollectionView!
    @IBOutlet weak var lblNoUploadedFiles: UILabel!

    // MARK: - VARIABLES

    var mediaAssets: [MediaAsset] = []

    let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone.current
        return f
    }()

    // MARK: - LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    // MARK: - SETUP

    func setupCollectionView() {

        collectionViewUploadedFiles.delegate = self
        collectionViewUploadedFiles.dataSource = self

        lblNoUploadedFiles.isHidden = !mediaAssets.isEmpty
    }

    // MARK: - OPEN PICKER

    @IBAction func uploadPhotos(_ sender: UIButton) {

        let picker = DKImagePickerController()

        picker.assetType = .allAssets
        picker.allowSwipeToSelect = true
        picker.allowSelectAll = true
        picker.showsCancelButton = true
        picker.autoCloseOnSingleSelect = false

        picker.didSelectAssets = { [weak self] assets in

            guard let self else { return }

            for asset in assets {

                self.handleAsset(asset)
            }
        }

        present(picker, animated: true)
    }

    // MARK: - HANDLE ASSET

    func handleAsset(_ asset: DKAsset) {

        guard let phAsset = asset.originalAsset else { return }

        let creationDate = phAsset.creationDate ?? Date()

        if phAsset.mediaType == .image {

            asset.fetchOriginalImage { image, info in

                guard let image else { return }

                DispatchQueue.main.async {

                    let media = MediaAsset(
                        image: image,
                        videoURL: nil,
                        date: creationDate,
                        isVideo: false
                    )

                    self.mediaAssets.append(media)
                    self.reloadUI()
                }
            }
        }

        else if phAsset.mediaType == .video {

            asset.fetchAVAsset { avAsset, info in

                guard let urlAsset = avAsset as? AVURLAsset else { return }

                DispatchQueue.main.async {

                    let media = MediaAsset(
                        image: self.generateThumbnail(url: urlAsset.url),
                        videoURL: urlAsset.url,
                        date: creationDate,
                        isVideo: true
                    )

                    self.mediaAssets.append(media)
                    self.reloadUI()
                }
            }
        }
    }

    // MARK: - THUMBNAIL

    func generateThumbnail(url: URL) -> UIImage? {

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

    // MARK: - UI UPDATE

    func reloadUI() {

        lblNoUploadedFiles.isHidden = !mediaAssets.isEmpty
        collectionViewUploadedFiles.reloadData()
    }

    // MARK: - GET DATE STRING

    func getDateString(_ date: Date) -> String {

        return isoFormatter.string(from: date)
    }
}

extension UploadPhotosVideosVCLib: UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return mediaAssets.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoCell",
            for: indexPath
        ) as! PhotoCell

        let media = mediaAssets[indexPath.item]

        cell.iv_Photo.image = media.image

        cell.onDelete = { [weak self] in

            self?.mediaAssets.remove(at: indexPath.item)
            self?.reloadUI()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {

        return CGSize(width: 120, height: 120)
    }
}

//
//  createAlbum.swift
//  Snabum
//
//  Created by mac on 07/10/2025.
import UIKit
import ProgressHUD
import Photos
import PhotosUI
import DKImagePickerController
import Alamofire

// MARK: - Models

struct SelectedPhoto {
    let id: String
    let image: UIImage?
    let type: MediaType
    let videoURL: URL?
    let dateImageTaken: String
}

enum CameraMode: String {
    case video
    case photo
}

enum MediaType {
    case photo
    case video
}

// MARK: - Upload VC

class UploadPhotosVC: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate,
                      UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var selectedPhotos: [SelectedPhoto] = []
    var onDismiss: (() -> Void)?
    var config = PHPickerConfiguration(photoLibrary: .shared())

    private var dropdown: DropdownMenu?

    @IBOutlet weak var albumName: UITextField!
    @IBOutlet weak var lblNoUploadedFiles: UILabel!
    @IBOutlet weak var collectionViewUploadedFiles: UICollectionView!
    @IBOutlet weak var btnDropDown: UIButton!

    var selectedDKAssets: [DKAsset] = []
    var selectedalbumID: Int? = nil
    var selectedFoldersAlbumNames: [String] = ["Add New Album"]
    private var albumsData: [AlbumsData]? = nil

    var isFromPhotoViewer: Bool? = false

    var isoFormatter: ISO8601DateFormatter? = nil
    var isoDateString: String? = nil

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewUploadedFiles.delegate = self
        collectionViewUploadedFiles.dataSource = self

        isoFormatter = ISO8601DateFormatter()
        isoDateString = isoFormatter?.string(from: Date())

        getAlbums()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !(isFromPhotoViewer ?? false) {
            // normal mode
        } else {
            btnDropDown.isEnabled = false
            albumName.isEnabled = false
            albumName.text = selectedFoldersAlbumNames.first
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isFromPhotoViewer = false
        btnDropDown.isEnabled = true
        albumName.isEnabled = true
        albumName.text = ""
    }

    // MARK: - CollectionView Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 75, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    // MARK: - CollectionView DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                      for: indexPath) as! PhotoCell

        cell.iv_Photo.image = selectedPhotos[indexPath.item].image

        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.selectedPhotos.remove(at: indexPath.item)
            self.collectionViewUploadedFiles.reloadData()
        }

        return cell
    }

    // MARK: - Albums

    func getAlbums() {

        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }

        AuthService.getAlbums { result in
            switch result {

            case .success(let (response, _)):
                ProgressHUD.dismiss()

                if let albums = response.data, albums.count > 0 {
                    self.albumsData = albums
                    self.selectedFoldersAlbumNames = ["Add New Folder"]
                    self.selectedFoldersAlbumNames.append(contentsOf: albums.map { $0.name ?? "" })
                } else {
                    self.albumsData = []
                }

            case .failure(let error):
                switch error {
                case .backendError(let data):
                    do {
                        let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                        ProgressHUD.failed(decoded.errors?.joined(separator: "\n") ?? "Error")
                    } catch {
                        ProgressHUD.failed("Data corrupted")
                    }
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Dropdown

    @IBAction func dropDownAlbum(_ sender: UIButton) {

        dropdown = DropdownMenu(items: selectedFoldersAlbumNames)

        dropdown?.show(from: sender, inView: self.view) { index, title in

            if index == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "CreateAlbumVC") as? CreateAlbumVC

                if let controller = controller {
                    if let sheet = controller.sheetPresentationController {
                        sheet.detents = [.custom(resolver: { _ in 270 })]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 25
                    }

                    controller.onCreateAlbum = { albumID, albumName in
                        self.showToastAlert(message: "Album Created")
                        self.albumName.text = albumName
                        self.getAlbums()
                        self.selectedalbumID = albumID
                    }

                    self.present(controller, animated: true)
                }

            } else {
                self.selectedalbumID = self.albumsData?[index - 1].id
                self.albumName.text = title
            }
        }
    }

    // MARK: - Pick Media

    @IBAction func uploadPhotos(_ sender: Any) {
        selectPhotosVideos(type: .photo)
    }

    @IBAction func uploadVideos(_ sender: Any) {
        selectPhotosVideos(type: .video)
    }

    @IBAction func clearAllSelectedPhotos(_ sender: Any) {
        selectedPhotos.removeAll()
        selectedDKAssets.removeAll()
        reloadCollectionView()
    }

    // MARK: - DKAsset Handling

    func handleAsset(_ asset: DKAsset) {

        guard let phAsset = asset.originalAsset else { return }
        let creationDate = phAsset.creationDate ?? Date()

        if phAsset.mediaType == .image {

            asset.fetchOriginalImage { image, _ in
                guard let image = image else { return }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                let date = formatter.string(from: creationDate)

                self.selectedPhotos.append(
                    SelectedPhoto(
                        id: phAsset.localIdentifier,
                        image: image,
                        type: .photo,
                        videoURL: nil,
                        dateImageTaken: date
                    )
                )

                self.reloadCollectionView()
            }
        }

        else if phAsset.mediaType == .video {

            asset.fetchAVAsset { avAsset, _ in
                guard let urlAsset = avAsset as? AVURLAsset else { return }

                DispatchQueue.main.async {

                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    let date = formatter.string(from: creationDate)

                    self.selectedPhotos.append(
                        SelectedPhoto(
                            id: phAsset.localIdentifier,
                            image: self.generateThumbnail(from: urlAsset.url),
                            type: .video,
                            videoURL: urlAsset.url,
                            dateImageTaken: date
                        )
                    )

                    self.reloadCollectionView()
                }
            }
        }
    }

    func selectPhotosVideos(type: MediaType) {

        let picker = DKImagePickerController()

        type == .video ? (picker.assetType = .allVideos) : (picker.assetType = .allPhotos)

        picker.allowSwipeToSelect = true
        picker.allowSelectAll = true
        picker.showsCancelButton = true
        picker.autoCloseOnSingleSelect = false

        picker.select(assets: selectedDKAssets)

        picker.didSelectAssets = { [weak self] assets in
            guard let self = self else { return }

            self.selectedDKAssets = assets
            self.selectedPhotos.removeAll()

            for asset in assets {
                self.handleAsset(asset)
            }
        }

        present(picker, animated: true)
    }

    // MARK: - Thumbnail

    private func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }

    // MARK: - SAVE BUTTON (FULLY INCLUDED)

    @IBAction func saveSettings(_ sender: Any) {

        guard !selectedPhotos.isEmpty else {
            showToastAlert(message: "No media selected")
            return
        }

        ProgressHUD.animate()

        let group = DispatchGroup()

        var successCount = 0
        var failureCount = 0

        for (index, media) in selectedPhotos.enumerated() {

            group.enter()

            uploadMediaOptimized(media, index: index) { success in
                if success {
                    successCount += 1
                } else {
                    failureCount += 1
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            ProgressHUD.dismiss()

            if failureCount > 0 {
                self.showAlertAction(
                    title: "Upload Completed",
                    message: "\(successCount) succeeded, \(failureCount) failed"
                ) {
                    self.resetUI()
                }
            } else {
                self.showToastAlert(message: "All media uploaded successfully!") {
                    self.resetUI()
                }
            }
        }
    }

    // MARK: - UPLOAD MEDIA (VIDEO + PHOTO)

    private func uploadMediaOptimized(_ media: SelectedPhoto,
                                      index: Int,
                                      completion: @escaping (Bool) -> Void) {

        guard let selectedalbumID = selectedalbumID else {
            completion(false)
            return
        }

        let baseURL = AppConfig.shared.configuration.api
        let urlString = "\(baseURL)/api/v1/user/albums/\(selectedalbumID)/media"

        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]

        if let token = TokenManager.shared.token { headers.add(name: "Access-Token", value: token) }
        if let client = TokenManager.shared.client { headers.add(name: "Client", value: client) }
        if let uid = TokenManager.shared.uid { headers.add(name: "Uid", value: uid) }

        request.headers = headers

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // BUILD BODY IN BACKGROUND THREAD
        DispatchQueue.global(qos: .userInitiated).async {

            var body = Data()

            // album_id
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"media[album_id]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(selectedalbumID)\r\n".data(using: .utf8)!)

            // type
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"media[media_type]\"\r\n\r\n".data(using: .utf8)!)
            body.append((media.type == .photo ? "photo" : "video").data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)

            // date
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"media[originally_taken_at]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(media.dateImageTaken)\r\n".data(using: .utf8)!)

            // file upload
            if media.type == .photo,
               let imageData = media.image?.jpegData(compressionQuality: 0.8) {

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"media[files][]\"; filename=\"photo_\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }

            else if media.type == .video {

                guard let videoURL = media.videoURL else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                // ⚠️ IMPORTANT: non-blocking file read
                guard let videoData = try? Data(contentsOf: videoURL) else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"media[files][]\"; filename=\"video_\(index).mp4\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                body.append(videoData)
                body.append("\r\n".data(using: .utf8)!)
            }

            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            // UPLOAD
            URLSession.shared.uploadTask(with: request, from: body) { _, _, error in

                DispatchQueue.main.async {
                    completion(error == nil)
                }

            }.resume()
        }
    }
    // MARK: - Helpers

    private func reloadCollectionView() {
        collectionViewUploadedFiles.reloadData()
        collectionViewUploadedFiles.isHidden = selectedPhotos.isEmpty
    }

    private func resetUI() {

        if isFromPhotoViewer ?? false {
            dismiss(animated: true) {
                self.onDismiss?()
            }
        }

        selectedPhotos.removeAll()
        selectedDKAssets.removeAll()
        selectedalbumID = nil
        albumName.text = ""
        reloadCollectionView()
    }
}

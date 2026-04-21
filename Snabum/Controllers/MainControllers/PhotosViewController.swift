//
//  PhotosViewController.swift
//  Snabum
//
//  Created by mac on 21/10/2025.
//
//
//  PhotosViewController.swift
//  Snabum
//

import UIKit
import SDWebImage
import ProgressHUD
import AVFoundation
import AVKit
import Alamofire

// MARK: - Model
struct HourlyMediaSection {
    let hour: String
    let media: [Media]
}

// MARK: - ViewController
class PhotosViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var viewNoPhotos: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var stackEditableButtons: UIStackView!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var deleteCoverButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    var isFromSharedAlbum: Bool = false
    var isPhotoSelector: Bool = false
    var canUserEdit: Bool = false
    var selectPhotoID: Int?

    weak var dataUpdater: AlbumDataUpdater?
    var sharedalbumsData: ShareList?
    var albumsData: AlbumsData?
    var onDismiss: (() -> Void)?

    private let imageCache = NSCache<NSString, UIImage>()
    private let ioQueue = DispatchQueue(label: "com.snabum.photos.queue", qos: .userInitiated)

    var groupedMedia: [HourlyMediaSection] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = isFromSharedAlbum
        SDImageCache.shared.config.shouldCacheImagesInMemory = true
        ProgressHUD.animate()

        if isFromSharedAlbum {
            fetchAlbumsData()
        } else {
            dataUpdater?.fetchLatestAlbums { [weak self] newData in
                guard let self = self else { return }
                self.albumsData = newData
                self.setupUI()
                self.setupCollectionView()
                ProgressHUD.dismiss()
            }
        }
    }

    // MARK: - Fetch
    func fetchAlbumsData() {
        guard let albumID = sharedalbumsData?.shareable?.id else { return }

        AuthService.showAlbum(albumID: albumID) { result in
            switch result {
            case .success(let (response, _)):
                ProgressHUD.dismiss()
                self.albumsData = response.data
                self.setupUI()
                self.setupCollectionView()

            case .failure(let error):
                ProgressHUD.failed(error.localizedDescription)
            }
        }
    }

    // MARK: - UI
    func setupUI() {

        deleteCoverButton.isHidden = (selectPhotoID == nil)
        stackEditableButtons.isHidden = !canUserEdit
        shareButton.isHidden = isFromSharedAlbum
        topView.isHidden = isPhotoSelector

        albumName.text = isFromSharedAlbum
            ? sharedalbumsData?.shareable?.name
            : albumsData?.name

        if let selectedID = selectPhotoID {
            albumsData?.media?.removeAll { $0.id == selectedID }
        }
    }

    // MARK: - Delete Album
    
    func deleteAlbum(){
        self.showAlertAction(title: "", message: "Are you sure you want to delete Album?", canShowCancel: true , actionConfirmationNormal: "Delete" ){
            
            AuthService.deleteAlbum(albumID: self.albumsData?.id ?? 0){
                result in
                switch result
                {
                case .success(_):
                    ProgressHUD.dismiss()
                    AppLogger.debug.info("Delete Album API successfull: Album Delete with ID = \(self.albumsData?.id ?? 0)")
                    self.showToastAlert(message: "Album Deleted"){
                        self.dismiss(animated: true)
                    }
                    
                case .failure(let error):
                    ProgressHUD.dismiss()
                    self.showToastAlert(message: error.localizedDescription)
                    AppLogger.debug.info("Album Delete API Failed:\(error.localizedDescription)")
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Collection Setup
    func setupCollectionView() {

        guard let count = albumsData?.mediaCount, count > 0 else {
            viewNoPhotos.isHidden = false
            collectionView.isHidden = true
            return
        }

        viewNoPhotos.isHidden = true
        collectionView.isHidden = false

        let layout = TwoColumnLeftAlignedFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        collectionView.collectionViewLayout = layout

        // 🔥 HEADER FIX
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.identifier
        )

        groupMediaByDateAndHour()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    // MARK: - Grouping
    private func groupMediaByDateAndHour() {
        guard let mediaList = albumsData?.media else { return }

        // Group dictionary
        var dateHourGroups: [String: [Media]] = [:]
        
        // Parse ISO8601 date strings correctly
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Formatter for display (date + hour)
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        displayFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Loop through each media item
        for media in mediaList {
            guard let dateString = media.originally_taken_at else { continue }
            
            // Try parsing with fractional seconds first
            var date: Date?
            if let parsed = isoFormatter.date(from: dateString) {
                date = parsed
            } else {
                // Try fallback without fractional seconds
                let fallbackFormatter = ISO8601DateFormatter()
                fallbackFormatter.formatOptions = [.withInternetDateTime]
                date = fallbackFormatter.date(from: dateString)
            }

            guard let validDate = date else { continue }

            // Convert to "yyyy-MM-dd HH:00" string
            let key = displayFormatter.string(from: validDate)
            dateHourGroups[key, default: []].append(media)
        }

        // Sort by actual date-time
        let sortedKeys = dateHourGroups.keys.sorted { key1, key2 in
            let df = DateFormatter()
            df.dateFormat = "MMM dd, yyyy HH:00"
            df.timeZone = TimeZone(secondsFromGMT: 0)
            guard let d1 = df.date(from: key1),
                  let d2 = df.date(from: key2) else { return false }
            return d1 < d2
        }

        // Convert to your display model
        groupedMedia = sortedKeys.map {
            HourlyMediaSection(hour: $0, media: dateHourGroups[$0] ?? [])
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    // MARK: - Actions
    @IBAction func deleteAlbum(_ sender: Any) {
        self.deleteAlbum()
    }
    @IBAction func deleteCover(_ sender: Any) {
        if self.canUserEdit{
            return
        }
        self.showAlertAction(title: "", message: "Are you sure you want to delete Cover?", canShowCancel: true , actionConfirmationNormal: "Delete" ){
            
            self.deleteCover()
            
            self.navigationController?.popViewController(animated: true)
        }
      
    }
    func deleteCover(){
        if isPhotoSelector{
            selectCoverImage(indexPath : nil , setCover: false)
            return
        }
    }
    
    @IBAction func addPhotosVideos(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        if let controller = main.instantiateViewController(withIdentifier: "UploadPhotosVC") as? UploadPhotosVC{
            controller.isFromPhotoViewer = true

           
            controller.selectedalbumID = albumsData?.id

            controller.selectedFoldersAlbumNames.removeAll()

            controller.selectedFoldersAlbumNames.append(self.albumsData?.name ?? "")
            controller.onDismiss = { [weak self] in
                if let self = self{
                    if self.isFromSharedAlbum{
                        self.fetchAlbumsData()
                    }else{
                        self.dataUpdater?.fetchLatestAlbums { [weak self] newData in
                            self?.albumsData = newData
                            self?.setupUI()
                            self?.setupCollectionView()
                        }
                    }
                }
                
            }
            self.navigationController?.present(controller, animated: true)
        }
    }

    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}



// MARK: - Tap Handling (FIXED)
extension PhotosViewController {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let media = groupedMedia[indexPath.section].media[indexPath.item]
        guard let selectedID = media.id else { return }

        var items: [MediaItem] = []

        for section in groupedMedia {
            for item in section.media {

                let type: MediaType = item.mediaType == "video" ? .video : .photo

                items.append(
                    MediaItem(
                        imageURL: item.url?.first ?? "",
                        videoURL: item.url?.first,
                        mediaID: item.id ?? 0,
                        date: item.originally_taken_at,
                        mediaType: type
                    )
                )
            }
        }

        let vc = FullImageViewController()
        vc.modalPresentationStyle = .fullScreen

        vc.items = items
        vc.startIndex = items.firstIndex { $0.mediaID == selectedID } ?? 0
        vc.canUserEdit = canUserEdit
        vc.isFromSharedFolder = isFromSharedAlbum

        vc.onDismiss = { [weak self] needsUpdate in
            guard let self = self, needsUpdate else { return }

            if self.isFromSharedAlbum {
                self.fetchAlbumsData()
            } else {
                self.dataUpdater?.fetchLatestAlbums { [weak self] newData in
                    self?.albumsData = newData
                    self?.setupUI()
                    self?.setupCollectionView()
                }
            }
        }

        present(vc, animated: true)
    }
}


// MARK: - Flow Layout
class TwoColumnLeftAlignedFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        let availableWidth = collectionView.bounds.width
            - sectionInset.left
            - sectionInset.right
            - minimumInteritemSpacing
        
        // Calculate item width for 2 columns
        let itemWidth = floor(availableWidth / 2)
        itemSize = CGSize(width: itemWidth, height: itemWidth) // square
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var updatedAttributes: [UICollectionViewLayoutAttributes] = []
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        for attr in attributes {
            let copiedAttr = attr.copy() as! UICollectionViewLayoutAttributes
            
            // Only adjust cell alignment
            if copiedAttr.representedElementCategory == .cell {
                if copiedAttr.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                copiedAttr.frame.origin.x = leftMargin
                leftMargin += copiedAttr.frame.width + minimumInteritemSpacing
                maxY = max(copiedAttr.frame.maxY, maxY)
            }
            
            updatedAttributes.append(copiedAttr)
        }
        
        return updatedAttributes
    }
}
  

// MARK: - Collection DataSource
extension PhotosViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupedMedia.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupedMedia[section].media.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AlbumPhotosCell",
            for: indexPath
        ) as! AlbumPhotosCell

        let mediaData = groupedMedia[indexPath.section].media[indexPath.item]

        guard
            
            let url = URL(string: mediaData.url?.first ?? "")
            
        else {
            cell.setImage(UIImage(systemName: "photo"))
            return cell
        }
        cell.configure(with: url , type : mediaData.mediaType == "photo" ? .photo : .video )
       

        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let delete = UIAction(title: "Delete",
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive) { _ in
                self.deleteItem(at: indexPath)
            }
            
            return UIMenu(title: "", children: [delete])
        }
    }
    
    func deleteItem(at indexPath: IndexPath){
        
        let mediaData = groupedMedia[indexPath.section].media[indexPath.item]
        
        self.showAlertAction(title: "", message: "Are you sure you want to delete?", canShowCancel: true , actionConfirmationNormal: "Delete" ){
            ProgressHUD.animate()
            AuthService.deleteMedia(mediaID: mediaData.id ?? 0){
                result in
                switch result
                {
                case .success(_):
                    ProgressHUD.dismiss()
                    AppLogger.debug.info("Delete Media API successfull: shared with ID = \(mediaData.id ?? 0)")
                    self.showToastAlert(message: "Media Deleted"){
                        self.dataUpdater?.fetchLatestAlbums { [weak self] newData in
                            if ((self?.isFromSharedAlbum) != nil ){
                                self?.fetchAlbumsData()
                            }else{
                                self?.dataUpdater?.fetchLatestAlbums { [weak self] newData in
                                    self?.albumsData = newData
                                    self?.setupUI()
                                    self?.setupCollectionView()
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    ProgressHUD.dismiss()
                    self.showToastAlert(message: error.localizedDescription)
                    AppLogger.debug.info("Delete API Failed:\(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func shareAlbum(_ sender: Any) {
        if !self.canUserEdit{
            return
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as? ShareViewController{
            controller.albumID = self.albumsData?.id // albumID
            controller.allbumName = self.albumsData?.name // albumName
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func saveImageToDocuments(image: UIImage, fileName: String) {
          ioQueue.async {
              guard let data = image.jpegData(compressionQuality: 0.85) else { return }
              let fileURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
              try? data.write(to: fileURL, options: .atomic)
          }
      }

      func saveThumbnail(_ image: UIImage, fileName: String) {
          ioQueue.async {
              let targetSize = CGSize(width: 300, height: 300 * image.size.height / image.size.width)
              let resizedImage = image.resized(to: targetSize)
              let fileURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
              if let data = resizedImage.jpegData(compressionQuality: 0.7) {
                  try? data.write(to: fileURL, options: .atomic)
              }
          }
      }

      private func getDocumentsDirectory() -> URL {
          FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      }
    
    func loadImageAsync(fileName: String, completion: @escaping (UIImage?) -> Void) {
            if let cached = imageCache.object(forKey: fileName as NSString) {
                completion(cached)
                return
            }
            ioQueue.async {
                let fileURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                guard let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe),
                      let img = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                self.imageCache.setObject(img, forKey: fileName as NSString)
                DispatchQueue.main.async { completion(img) }
            }
        }
    
    // MARK: - HEADER
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as! HeaderView
            header.titleLabel.text = groupedMedia[indexPath.section].hour
            return header
        }
        return UICollectionReusableView()
    }
    
}

// MARK: - PhotosViewController DelegateFlowLayout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
   
    func playVideo(url: URL, from viewController: UIViewController) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error:", error)
        }

        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player

        viewController.present(playerVC, animated: true) {
            player.play()
        }
    }
    func selectCoverImage(indexPath : IndexPath? , setCover : Bool?){
        var id = self.selectPhotoID ?? 0
        if let indexPath = indexPath{
            id = self.groupedMedia[indexPath.section].media[indexPath.item].id ?? 0
        }
        AuthService.setAlbumCover(photoID: id , AlbumID: self.albumsData?.id ?? 0, setCover: setCover!){
            result in
            switch result
            {
            case .success(_):
                ProgressHUD.dismiss()
                AppLogger.debug.info("Set Cover Album API successfull: Album Delete with ID = \(self.albumsData?.id ?? 0)")
                self.showToastAlert(message: "Album Cover set"){
                    self.dismiss(animated: true){
                        self.onDismiss!()
                    }
                }
                
            case .failure(let error):
                ProgressHUD.dismiss()
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Set Cover Album API Failed:\(error.localizedDescription)")
            }
        }
        
        self.dismiss(animated: true)
    }
}
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


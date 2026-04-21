//
//  AlbumsViewController.swift
//  Snabum
//
//  Created by mac on 17/10/2025.
//

import UIKit
import ProgressHUD

class AlbumsViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var viewNoAlbum: UIView!
    @IBOutlet weak var tableAlbums: UITableView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var stackEditButtons: UIStackView!

    
    // MARK: - Properties
    
    var photoID: Int?
    var isFromSharedFolder: Bool? = false
    var canUserEdit: Bool? = false
    
    private var albumsData: [AlbumsData]?
    private var selectedAlbumIndex = 0
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAlbumsData()
    }
    
    
    // MARK: - UI Setup
    
    private func configureUI() {
        stackEditButtons.isHidden = !(canUserEdit ?? false)
        shareButton.isHidden = isFromSharedFolder!
        print(isFromSharedFolder)
    }
    
    private func configureTableView() {
        tableAlbums.delegate = self
        tableAlbums.dataSource = self
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func addAlbumViewButton(_ sender: Any) {
        presentCreateAlbum()
    }
    
    @IBAction func addAlbum(_ sender: Any) {
        presentCreateAlbum()
    }
    
    @IBAction func shareAlbum(_ sender: Any) {
        guard !(canUserEdit ?? false) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let controller = storyboard.instantiateViewController(
            withIdentifier: "ShareViewController"
        ) as? ShareViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Album Creation
    
    private func presentCreateAlbum() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "CreateAlbumVC"
        ) as? CreateAlbumVC else { return }
        
        configureSheet(controller)
        
        controller.onCreateAlbum = { [weak self] _, _ in
            guard let self = self else { return }
            
            self.showToastAlert(message: "Album Created")
            self.fetchAlbumsData()
        }
        
        present(controller, animated: true)
    }
    
    
    private func configureSheet(_ controller: UIViewController) {
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in return 270 })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
    }
    
    
    // MARK: - API Calls
    
    private func fetchAlbumsData() {
        getAlbums { [weak self] data in
            guard let self = self else { return }
            
            self.albumsData = data
            self.tableAlbums.reloadData()
            self.configureUI()
        }
    }
    
    
    private func getAlbums(completion: @escaping ([AlbumsData]) -> Void) {
        
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        
        AuthService.getAlbums { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let (response, _)):
                
                AppLogger.general.info("Albums fetched successfully")
                ProgressHUD.dismiss()
                
                guard let albums = response.data,
                      !albums.isEmpty else {
                    
                    self.tableAlbums.isHidden = true
                    self.viewNoAlbum.isHidden = false
                    completion([])
                    return
                }
                
                self.viewNoAlbum.isHidden = true
                self.tableAlbums.isHidden = false
                
                completion(albums)
                
                
            case .failure(let error):
                
                AppLogger.error.error("Get Album failed: \(error.localizedDescription)")
                
                switch error {
                    
                case .backendError(let data):
                    self.handleBackendError(data)
                    
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: - Error Handling
    
    private func handleBackendError(_ data: Data) {
        do {
            let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            
            if let messages = decoded.errors {
                ProgressHUD.failed(messages.joined(separator: "\n"))
            } else {
                ProgressHUD.failed("Something went wrong.")
            }
            
        } catch {
            ProgressHUD.failed("Data corrupted")
        }
    }
}


// MARK: - UITableView Delegate & DataSource

extension AlbumsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return albumsData?.count ?? 1
    }

    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let albums = albumsData,
              albums.count > 0 else {
            
            return tableView.dequeueReusableCell(
                withIdentifier: "NoMediaTableViewCell"
            ) as! NoMediaTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AlbumTableViewCell"
        ) as! AlbumTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    private func configureCell(
        _ cell: AlbumTableViewCell,
        indexPath: IndexPath
    ) {
        
        let album = albumsData?[indexPath.row]
        
        cell.coverImage = nil
        cell.albumCoverImageView.image = UIImage(named: "default_cover_album")
        cell.albumNameLabel.text = album?.name
        
        cell.onButtonTap = { [weak self] in
            self?.didTapButton(at: indexPath)
        }
        
        loadAlbumCover(for: cell, album: album)
        
        cell.editCoverView.isHidden = !(canUserEdit ?? false)
    }
    
    
    private func loadAlbumCover(
        for cell: AlbumTableViewCell,
        album: AlbumsData?
    ) {
        guard let coverMedia = album?.media?
                .first(where: { $0.coverPhoto == true }),
              
              let coverURLString = coverMedia.url?.first,
              let coverURL = URL(string: coverURLString)
        else { return }
        
        photoID = coverMedia.id
        
        cell.albumCoverImageView.sd_setImage(
            with: coverURL,
            placeholderImage: UIImage(named: "default_cover_album")
        ) { image, _, _, _ in
            
            if let loadedImage = image {
                cell.coverImage = loadedImage
            }
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        guard albumsData?.count ?? 0 > 0 else {
            presentCreateAlbum()
            return
        }
        
        openPhotosController(indexPath: indexPath, isSelector: false)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: - Navigation

extension AlbumsViewController {
    
    private func didTapButton(at indexPath: IndexPath) {
        openPhotosController(indexPath: indexPath, isSelector: true)
    }
    
    
    private func openPhotosController(
        indexPath: IndexPath,
        isSelector: Bool
    ) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "PhotosViewController"
        ) as? PhotosViewController else { return }
        
        controller.isPhotoSelector = isSelector
        controller.canUserEdit = canUserEdit!
        controller.selectPhotoID = photoID
        controller.isFromSharedAlbum = isFromSharedFolder!
        controller.albumsData = albumsData?[indexPath.row]
        
        controller.onDismiss = { [weak self] in
            self?.fetchAlbumsData()
        }
        
        selectedAlbumIndex = indexPath.row
        
        if isSelector {
            present(controller, animated: true)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

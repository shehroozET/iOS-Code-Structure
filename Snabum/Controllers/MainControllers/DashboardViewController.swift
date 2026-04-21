//
//  DashboardViewController.swift
//  Snabum
//
//  Created by mac on 31/07/2025.
//

import UIKit
import ProgressHUD

// MARK: - Protocol

protocol AlbumDataUpdater: AnyObject {
    func fetchLatestAlbums(completion: @escaping (AlbumsData) -> Void)
}


// MARK: - Protocol Implementation

extension DashboardViewController: AlbumDataUpdater {
    
    func fetchLatestAlbums(completion: @escaping (AlbumsData) -> Void) {
        getAlbums { [weak self] data in
            guard let self = self else { return }
            
            self.albumsData = data
            completion(data[self.selectedAlbumIndex])
        }
    }
}


// MARK: - DashboardViewController

class DashboardViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var noSharedFolderView: UIView!
    @IBOutlet weak var tableFolders: UITableView!
    @IBOutlet weak var sagementControll: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var lblAllFolders: UILabel!
    @IBOutlet weak var noFolderView: UIView!
    
    
    // MARK: - Properties
    
    private var albumsData: [AlbumsData]?
    private var sharedalbumsData: [ShareList]?
    
    weak var dataUpdater: AlbumDataUpdater?
    
    var isFromSharedAlbum: Bool? = false
    private var canShowSharedFolder: Bool = false
    private var selectedAlbumIndex: Int = 0
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSegmentAppearance()
        configureTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadInitialData()
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - UI Configuration
    
    private func configureSegmentAppearance() {
        let appearance = UISegmentedControl.appearance()
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.black],
            for: .normal
        )
        
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
    }
    
    
    private func configureTableView() {
        tableFolders.delegate = self
        tableFolders.dataSource = self
    }
    
    
    private func loadInitialData() {
        if canShowSharedFolder {
            getSharedAlbums()
        } else {
            fetchAlbums()
        }
    }
    
    
    // MARK: - API Calls
    
    private func fetchAlbums() {
        getAlbums { [weak self] data in
            guard let self = self else { return }
            
            self.albumsData = data
            self.tableFolders.reloadData()
        }
    }
    
    
    func getSharedAlbums() {
        
        ProgressHUD.animate()
        
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        
        AuthService.getSharedFolders { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let (response, _)):
                
                AppLogger.general.info("Shared folders fetched")
                ProgressHUD.dismiss()
                
                guard let folders = response.data else {
                    self.showEmptySharedFolders()
                    return
                }
                
                self.sharedalbumsData = folders.filter {
                    String($0.sharedWithUser?.id ?? 0) ==
                    UserSettings.shared.id
                }
                
                self.updateSharedFolderUI()
                
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    
    private func updateSharedFolderUI() {
        
        tableFolders.reloadData {
            self.tableFolders.isHidden = false
            self.noSharedFolderView.isHidden =
                self.sharedalbumsData?.count ?? 0 > 0
            
            self.noFolderView.isHidden = true
        }
    }
    
    
    private func showEmptySharedFolders() {
        albumsData = []
        tableFolders.reloadData()
        
        tableFolders.isHidden = true
        noSharedFolderView.isHidden = false
        noFolderView.isHidden = true
    }
    
    
    func getAlbums(completion: @escaping ([AlbumsData]) -> Void) {
        
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
                    
                    self.tableFolders.isHidden = true
                    self.noFolderView.isHidden = false
                    
                    completion([])
                    return
                }
                
                self.noFolderView.isHidden = true
                self.tableFolders.isHidden = false
                
                completion(albums)
                
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    
    // MARK: - Segment Control
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            showAllAlbums()
            
        case 1:
            showSharedAlbums()
            
        default:
            break
        }
    }
    
    
    private func showAllAlbums() {
        canShowSharedFolder = false
        isFromSharedAlbum = false
        addButton.isHidden = false
        lblAllFolders.text = "All Albums"
        noSharedFolderView.isHidden = true
        
        fetchAlbums()
    }
    
    
    private func showSharedAlbums() {
        canShowSharedFolder = true
        isFromSharedAlbum = true
        addButton.isHidden = true
        
        lblAllFolders.text = "Shared Albums"
        
        getSharedAlbums()
    }
    
    
    // MARK: - Add Album
    
    @IBAction func addNewFolder(_ sender: Any) {
        presentCreateAlbum()
    }
    
    
    @IBAction func AddFolders(_ sender: Any) {
        presentCreateAlbum()
    }
    
    
    private func presentCreateAlbum() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "CreateAlbumVC"
        ) as? CreateAlbumVC else { return }
        
        configureSheet(controller)
        
        controller.onCreateAlbum = { [weak self] _, _ in
            guard let self = self else { return }
            
            self.showToastAlert(message: "Album Created")
            self.fetchAlbums()
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
    
    
    // MARK: - Navigation
    
    @IBAction func showNotifications(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(
            withIdentifier: "NotificationsViewController"
        )
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: - Error Handling
    
    private func handleError(_ error: APIError) {
        
        AppLogger.error.error("Share folder API failed: \(error.localizedDescription)")
        switch error {
            
        case .backendError(let data):
            
            do {
                let decoded = try JSONDecoder().decode(
                    APIErrorResponse.self,
                    from: data
                )
                
                if let messages = decoded.errors {
                    ProgressHUD.failed(messages.joined(separator: "\n"))
                } else {
                    ProgressHUD.failed("Something went wrong.")
                }
                
            } catch {
                ProgressHUD.failed("Data corrupted")
            }
            
        default:
            ProgressHUD.failed(error.localizedDescription)
        }
    }
}


// MARK: - UITableView

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        if canShowSharedFolder {
            return sharedalbumsData?.count ?? 0
        }
        
        return albumsData?.count ?? 0
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FolderCell",
            for: indexPath
        ) as! FolderCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    private func configureCell(
        _ cell: FolderCell,
        indexPath: IndexPath
    ) {
        
        if canShowSharedFolder {
            
            cell.shareWithView.isHidden = false
            cell.shareWithUser.text =
                sharedalbumsData?[indexPath.row].sharedWithUser?.name ?? "-"
            
            cell.folderName.text =
                sharedalbumsData?[indexPath.row].shareable?.name
            
            cell.totalAlbumCount.text =
                String(sharedalbumsData?[indexPath.row]
                    .shareable?.mediaCount ?? 0)
            
            let date = sharedalbumsData?[indexPath.row].grantedAt
            cell.folderDate.text = getDateInString(date: date ?? "")
            
        } else {
            
            cell.shareWithView.isHidden = true
            
            cell.folderName.text =
                albumsData?[indexPath.row].name
            
            cell.totalAlbumCount.text =
                String(albumsData?[indexPath.row].mediaCount ?? 0)
            
            let date = albumsData?[indexPath.row].createdAt
            cell.folderDate.text = getDateInString(date: date ?? "")
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
       
        defer {
            tableView.deselectRow(at: indexPath, animated: false)
        }

        let hasSharedAlbums = (sharedalbumsData?.isEmpty == false)
        let hasNormalAlbums = (albumsData?.isEmpty == false)

        let isSharedFlow = isFromSharedAlbum == true

        let hasAlbums = isSharedFlow ? hasSharedAlbums : hasNormalAlbums

        guard hasAlbums else {
            presentCreateAlbum()
            return
        }

        openPhotosController(indexPath: indexPath)
    }
}


// MARK: - Navigation

extension DashboardViewController {
    
    private func openPhotosController(indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "PhotosViewController"
        ) as? PhotosViewController else { return }

        controller.dataUpdater = self

        let isSharedFlow = (isFromSharedAlbum == true)

        controller.isFromSharedAlbum = isSharedFlow

        selectedAlbumIndex = indexPath.row

        if isSharedFlow {

            guard let sharedItem = sharedalbumsData,
                  indexPath.row < sharedItem.count else { return }

            controller.sharedalbumsData = sharedItem[indexPath.row]
            controller.canUserEdit = sharedItem[indexPath.row].role == "editor"
            controller.albumsData = nil

        } else {

            guard let normalAlbums = albumsData,
                  indexPath.row < normalAlbums.count else { return }
            controller.canUserEdit = true
            controller.albumsData = normalAlbums[indexPath.row]
            controller.sharedalbumsData = nil
        }

        navigationController?.pushViewController(controller, animated: true)
    }
}

//
//  ShareViewController.swift
//  Snabum
//
//  Created by mac on 10/10/2025.
//

import UIKit
import ProgressHUD
import AlamofireImage

class ShareViewController: UIViewController , UITextFieldDelegate , AlbumShareCellDelegate , AlbumDeleteCellDelegate{
    func didTapDelete(userID: String, name: String) {
        AuthService.unSharedAlbum(albumID: userID){
            result in
            switch result
            {
            case .success(_):
                AppLogger.debug.info("Unshared API successfull: shared with ID = \(userID) name =  \(name)")
                self.showToastAlert(message: "List Shared Permission removed for \(name)")
                self.getSharedMembersList()
           
                
            case .failure(let error):
                AppLogger.debug.info("UnShare API Failed: shared with ID = \(userID) name =  \(name) , folderID = \(String(self.albumID ?? 0))")
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Unshared API Failed:\(error.localizedDescription)")
            }
        }
    }
    
    func didTapShare(userID: String , name : String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SharePopUpController") as? SharePopUpController
        controller?.AlbumName = "Name"
        controller?.userToShareName = name
        if let controller = controller {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in return 270 })]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 25
            }
            
            controller.onShareAlbum = { canEdit in
                self.canEdit = canEdit
                self.shareAlbum(userID: userID, name: name)
            }
            
            self.present(controller, animated: true)
        }
    }
    func shareAlbum(userID: String , name : String){
        AuthService.shareAlbum(albumID: String(albumID ?? 0), userIDToShareAlbum: userID, canEdit: canEdit ?? false){
            result in
            switch result
            {
            case .success(_):
                AppLogger.debug.info("Share API successfull: shared with ID = \(userID) name =  \(name)")
                self.showToastAlert(message: "List Shared with \(name)")
                self.getSharedMembersList()
          
            case .failure(let error):
                AppLogger.debug.info("Share API Failed: shared with ID = \(userID) name =  \(name) , folderID = \(String(self.albumID ?? 0))")
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Share API Failed:\(error.localizedDescription)")
            }
        }
    }

    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var noItemsView: UILabel!
    @IBOutlet weak var lblSearchUsers: UILabel!
    @IBOutlet weak var tf_search: UITextField!
    @IBOutlet weak var tableFriends: UITableView!
    var albumID : Int? = nil
    var allbumName : String? = nil
    var sharedListData : [ListData]?
    var isSearching = false
    var isSharedUsersExists = false
    var searchDebounceTimer : Timer?
    var canEdit : Bool? = false
    
    @IBOutlet weak var searchView: UIView!
    var data : [UsersFound] = []
    
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        self.searchView.layer.borderColor = UIColor.lightGray.cgColor
        self.searchView.layer.borderWidth = 0.3
        self.folderName.text = "Share Album"
        
        getSharedMembersList()
    }
    
    func getSharedMembersList(){
        AuthService.getSharedMembersList{
            result in
            switch result
            {
            case .success(let (response, _)):
                AppLogger.debug.info("Get shared members List API successfull")
                self.sharedListData = response.data
                self.isSharedUsersExists = self.sharedListData?.count ?? 0 > 0
                self.setAlreadySharedUserList()
                
            case .failure(let error):
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Get shared Members API Failed:\(error.localizedDescription)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Share Bucket"
        self.setupNavigationBackButton(){
            self.navigationController?.popViewController(animated: true)
        }
        
        
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      
        
    }
    @objc func reloadData(){
        
        self.getSharedMembersList()
        
        self.tableFriends.reloadData {
            ProgressHUD.dismiss()
            self.setAlreadySharedUserList()
        }
        
    }

    @IBAction func navigateBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func setAlreadySharedUserList(){
        if isSharedUsersExists{
            self.lblSearchUsers.isHidden = true
            self.noItemsView.isHidden = true
            self.tableFriends.isHidden = false
            
        } else {
            self.lblSearchUsers.isHidden = false
        }
        tableFriends.reloadData()
        tableFriends.delegate = self
        tableFriends.dataSource = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if query.isEmpty {
            isSearching = false
            noItemsView.isHidden = true
            data = []
            setAlreadySharedUserList()
        } else {
            isSearching = true
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                ProgressHUD.animate()
                self.searchUser(text : query)
                
            }
        }
    }
    func searchUser(text : String){
        AuthService.searchUser(email: text){
            result in
            switch result {
            case .success(let (response, _)):
                AppLogger.general.info("API user search Successfull: user Search API")
                
                self.tableFriends.isHidden = false
                self.data = response.data ?? []
                
                self.tableFriends.delegate = self
                self.tableFriends.dataSource  = self
                if let data = response.data , data.count > 0{
                    self.noItemsView.isHidden = true
                    self.tableFriends.isHidden = false
                } else {
                    self.noItemsView.isHidden = false
                    self.lblSearchUsers.isHidden = true
                    self.tableFriends.isHidden = true
                }
                
                self.tableFriends.reloadData {
                    ProgressHUD.dismiss()
                }
            case .failure(let error):
                AppLogger.error.error("User Search API failed: \(error.localizedDescription)")
                switch error {
                case .backendError(let data):
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
                    
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }
}
extension ShareViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSharedUsersExists && !isSearching{
            return sharedListData?.count ?? 0
        }
        return self.data.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(sharedListData?.count ?? 0 > 0 || isSearching){
            let headerView = UIView()
            headerView.backgroundColor = UIColor.init(named: "headerBG")
            headerView.layer.cornerRadius = 10
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = (isSharedUsersExists && !isSearching) ? "Shared With" : "Share with"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = .darkGray
            
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(sharedListData?.count ?? 0 > 0 || isSearching){
            return 40
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (isSharedUsersExists && !isSearching) ? "Shared With" : "Share with"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsTableViewCell", for: indexPath) as! FindFriendsTableViewCell
       
        if isSharedUsersExists , !isSearching {
            if let sharedUser = sharedListData?[indexPath.row]{
                cell.nameLabel.text = sharedUser.sharedWithUser?.name ?? ""
                cell.profileImageView.image = createInitialImage(name: sharedUser.sharedWithUser?.name ?? "G")
                cell.actionButton.isHidden = false
                cell.deleteDelegate = self
                cell.isShared = true
                cell.userID = String(sharedUser.id ?? 0)
                self.lblSearchUsers.isHidden = true
                cell.userName = sharedUser.sharedWithUser?.name ?? ""
                setButton(cell: cell , canRemove: true)
            }
        } else {
            let data = data[indexPath.row]
            
            cell.nameLabel.text = data.name ?? ""
            cell.isShared = false
            self.lblSearchUsers.isHidden = true
            if let urlString = data.pictureURL, let url = URL(string: urlString) {
                cell.profileImageView.af.setImage(withURL: url)
            } else {
                cell.profileImageView.image = createInitialImage(name: data.name ?? "G")
            }
            cell.userID = String(data.id ?? 0)
            cell.userName = data.name ?? ""
            cell.shareDelegate = self
           
            let isShared = self.sharedListData?.contains(where: { $0.sharedWithUser?.id == data.id! }) ?? false
            if isShared{
                cell.actionButton.isHidden = true
            }
            setButton(cell: cell, canRemove: false)
            
        }
        return cell
        
    }
    
    func setButton(cell : FindFriendsTableViewCell , canRemove : Bool){
        if canRemove{
           
            cell.actionButton.setTitle("remove", for: .normal)
            cell.actionButton.tintColor = .red
            cell.actionButton.titleLabel?.textColor = .red
            cell.actionButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 12)
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let image = UIImage(systemName: "trash", withConfiguration: config)
            cell.actionButton.setImage(image, for: .normal)
        } else {
           
            cell.actionButton.setTitle("share", for: .normal)
            cell.actionButton.tintColor = UIColor(named: "CapsuleBG")
            cell.actionButton.titleLabel?.textColor = .green
            cell.actionButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 12)
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
            cell.actionButton.setImage(image, for: .normal)
        }
    }
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

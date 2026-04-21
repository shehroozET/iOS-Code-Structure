//
//  FindFriendsTableViewCell.swift
//  Snabum
//
//  Created by mac on 20/10/2025.
//

import UIKit

// MARK: - Delegates

protocol AlbumShareCellDelegate: AnyObject {
    func didTapShare(userID: String, name: String)
}

protocol AlbumDeleteCellDelegate: AnyObject {
    func didTapDelete(userID: String, name: String)
}

// MARK: - Cell

final class FindFriendsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: - Delegates
    
    weak var shareDelegate: AlbumShareCellDelegate?
    weak var deleteDelegate: AlbumDeleteCellDelegate?
    
    // MARK: - Properties
    
    var userID: String?
    var userName: String?
    var isShared: Bool = false

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Setup

private extension FindFriendsTableViewCell {
    
    func setupUI() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
    }
}

// MARK: - Actions

extension FindFriendsTableViewCell {
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        handleAction()
    }
    
    private func handleAction() {
        guard let id = userID else { return }
        
        let name = userName ?? ""
        
        if isShared {
            deleteDelegate?.didTapDelete(userID: id, name: name)
        } else {
            shareDelegate?.didTapShare(userID: id, name: name)
        }
    }
}

// MARK: - Reuse

private extension FindFriendsTableViewCell {
    
    func resetCell() {
        profileImageView.image = nil
        nameLabel.text = nil
        userID = nil
        userName = nil
        isShared = false
    }
}

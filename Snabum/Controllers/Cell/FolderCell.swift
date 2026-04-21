//
//  AlbumCell.swift
//  Snabum
//
//  Created by mac on 30/09/2025.
//

import UIKit

class FolderCell: UITableViewCell {

    @IBOutlet weak var shareWithUser: UILabel!
    @IBOutlet weak var shareWithView: UIView!
    @IBOutlet weak var folderCover: UIImageView!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var folderDate: UILabel!
    @IBOutlet weak var totalAlbumCount: UILabel!
    @IBOutlet weak var folderView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.folderView.layer.cornerRadius = 10
        self.folderName.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMinYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

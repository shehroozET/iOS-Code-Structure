//
//  PhotoCell.swift
//  Snabum
//
//  Created by mac on 13/10/2025.
//
import UIKit

class PhotoCell: UICollectionViewCell {
    var onDelete: (() -> Void)?
    
   
    @IBOutlet weak var iv_Photo: UIImageView!
    
    @IBAction func DeletePhoto(_ sender: Any) {
        onDelete!()
    }
}

//
//  AlbumTableViewCell.swift
//  Snabum
//
//  Created by mac on 21/10/2025.
//

import UIKit

final class AlbumTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var albumCoverImageView1: UIImageView!
    @IBOutlet weak var albumCoverImageView2: UIImageView!
    @IBOutlet weak var editCoverView: UIView!
    
    // MARK: - Properties
    
    var onButtonTap: (() -> Void)?
    var indexPath: IndexPath?
    
    var coverImage: UIImage? {
        didSet {
            applyStackedCoverImages()
        }
    }

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

private extension AlbumTableViewCell {
    
    func setupUI() {
        configureImageViews()
    }
    
    func configureImageViews() {
        let imageViews = [
            albumCoverImageView,
            albumCoverImageView1,
            albumCoverImageView2
        ]
        
        imageViews.forEach { imageView in
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = 10
            imageView?.layer.borderWidth = 2.5
            imageView?.layer.borderColor = UIColor.white.cgColor
        }
    }
}

// MARK: - Configuration

private extension AlbumTableViewCell {
    
    func applyStackedCoverImages() {
        guard let image = coverImage else { return }

        albumCoverImageView1.layer.opacity = 0.7
        albumCoverImageView2.layer.opacity = 0.8
        
        let imageViews = [
            albumCoverImageView,
            albumCoverImageView1,
            albumCoverImageView2
        ]
        
        imageViews.forEach { imageView in
            imageView?.image = image
            removeTopBorder(from: imageView)
        }
    }
}

// MARK: - Helpers

private extension AlbumTableViewCell {
    
    func removeTopBorder(from view: UIView?) {
        view?.layer.sublayers?
            .filter { $0.name == "topBorder" }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    func addTopBorderOverlay(to view: UIView) {
        let border = CALayer()
        border.name = "topBorder"
        border.frame = view.bounds
        border.cornerRadius = view.layer.cornerRadius
        border.borderWidth = 2
        border.borderColor = UIColor.gray.withAlphaComponent(0.9).cgColor
        
        view.layer.addSublayer(border)
    }
}

// MARK: - Reuse

private extension AlbumTableViewCell {
    
    func resetCell() {
        coverImage = nil
        
        let imageViews = [
            albumCoverImageView,
            albumCoverImageView1,
            albumCoverImageView2
        ]
        
        imageViews.forEach {
            $0?.image = nil
            $0?.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}

// MARK: - Actions

extension AlbumTableViewCell {
    
    @IBAction func changeAlbum(_ sender: Any) {
        onButtonTap?()
    }
}

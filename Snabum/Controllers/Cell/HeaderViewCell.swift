//
//  HeaderViewCell.swift
//  Snabum
//
//  Created by mac on 13/10/2025.
//

import UIKit

class HeaderView: UICollectionReusableView {
    static let identifier = "HourHeaderView"
       
    private let backgroundContainer = UIView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // White background covering full width
        backgroundContainer.backgroundColor = .white
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundContainer)
        
        NSLayoutConstraint.activate([
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Label setup
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(named: "AppMainColor") ?? .systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor)
        ])
        
        // Optional subtle separator line at bottom
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

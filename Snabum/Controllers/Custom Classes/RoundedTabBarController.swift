//
//  RoundTabbar.swift
//  Snabum
//
//  Created by mac on 30/09/2025.
//

import UIKit

class RoundedTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let horizontalInset: CGFloat = 50  // padding from left/right
    private let verticalOffset: CGFloat = 0    // move items down inside shape
    private let selectionLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Custom background shape
        let bgLayer = CAShapeLayer()
        bgLayer.path = UIBezierPath(
            roundedRect: CGRect(
                x: 20,
                y: self.tabBar.bounds.minY - 3,
                width: self.tabBar.bounds.width - 40,
                height: self.tabBar.bounds.height + 10
            ),
            cornerRadius: (self.tabBar.frame.width / 2)
        ).cgPath
        
        bgLayer.shadowColor = UIColor.lightGray.cgColor
        bgLayer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        bgLayer.shadowRadius = 25.0
        bgLayer.shadowOpacity = 0.3
        bgLayer.borderWidth = 1.0
        bgLayer.opacity = 1.0
        bgLayer.isHidden = false
        bgLayer.masksToBounds = false
        bgLayer.fillColor = UIColor.white.cgColor
        
        self.tabBar.layer.insertSublayer(bgLayer, at: 0)
        
        guard let items = self.tabBar.items else { return }
        
        // Push icons downward
        for item in items {
            item.imageInsets = UIEdgeInsets(top: verticalOffset, left: 0, bottom: -verticalOffset, right: 0)
        }
        
        // Custom spacing
        let availableWidth = self.tabBar.bounds.width - (horizontalInset * 2)
        self.tabBar.itemWidth = availableWidth / CGFloat(items.count)
        self.tabBar.itemPositioning = .centered
        
        // Transparent tint setup
        self.tabBar.tintColor = .white
        self.tabBar.unselectedItemTintColor = UIColor(named: "button_color")
        
        // Remove black line
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.clipsToBounds = false
        
        let circularIndicator = UIImage.createCircularIndicator(color: UIColor(named: "AppMainColor")!, diameter: 44)
        tabBar.selectionIndicatorImage = circularIndicator
        
    }
    
    
   
   
}

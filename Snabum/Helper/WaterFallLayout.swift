//
//  WaterFallLayout.swift
//  Snabum
//
//  Created by mac on 23/10/2025.
//

import UIKit
import UIKit

class WaterFallLayout: UICollectionViewLayout {
    var numberOfColumns = 2
    var cellPadding: CGFloat = 6
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView, cache.isEmpty else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            // Ask delegate for height
            let photoHeight: CGFloat
            if let delegate = collectionView.delegate as? WaterFallLayoutDelegate {
                photoHeight = delegate.collectionView(collectionView, heightForPhotoAt: indexPath, with: columnWidth)
            } else {
                photoHeight = 200
            }
            
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column],
                               width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            // Move to next shortest column
            if let minY = yOffset.min(), let minIndex = yOffset.firstIndex(of: minY) {
                column = minIndex
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}

protocol WaterFallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat
}

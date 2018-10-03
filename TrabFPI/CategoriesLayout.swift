import UIKit

protocol LayoutDelegate: class {
    func getCellSize(for indexPath: IndexPath) -> CGSize
}


class CategoriesLayout: UICollectionViewLayout {
    
    weak var delegate: LayoutDelegate?
    
    private let cellHeight: CGFloat = 75
    private let cellWidth: CGFloat = 74
    
    private var lineHeight: CGFloat {
        return cellHeight + 2 * cellPaddingHeight
    }
    
    private var numberOfLines: Int {
        return 1
    }
    private var cellPaddingWidth: CGFloat = 2.5
    private var cellPaddingHeight: CGFloat = 3
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.bottom + insets.top)
    }
    private var contentWidth: CGFloat = 0

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            return
        }
        guard collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > 0 else {
            return
        }
        cache = []
        var yOffset = [CGFloat]()
        for line in 0 ..< numberOfLines {
            yOffset.append(CGFloat(line) * lineHeight)
        }
        var xOffset = [CGFloat](repeating: 0, count: numberOfLines)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let size = delegate?.getCellSize(for: IndexPath(item: item, section: 0)) ?? CGSize(width: 0, height: 0)
            
            let width = cellPaddingWidth * 2 + size.width
            
        
            let frame = CGRect(x: xOffset[0], y: yOffset[0], width: width, height: 2 * cellPaddingHeight + size.height)
            
            let insetFrame = frame.insetBy(dx: cellPaddingWidth, dy: cellPaddingHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            xOffset[0] = xOffset[0] + width
            contentWidth = max(contentWidth, frame.maxX)
            
            
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

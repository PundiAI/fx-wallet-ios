
import WKKit
class NotificationFoldLayout: UICollectionViewFlowLayout {
    private var insertedIndexPaths:Array<IndexPath>?
    private var removedIndexPaths:Array<IndexPath>?       var attributes0 = Array<UICollectionViewLayoutAttributes>()
    var attributes1 = Array<UICollectionViewLayoutAttributes>()
    var contentSize: CGSize = CGSize(width: 0, height: 0)
    var contentHeight:CGFloat = NotificationListViewController.minContentHeight
    var itemSpacing:CGFloat = 10.auto()
    private var delegate:NotificationLayoutDelegate!
    init(delegate:NotificationLayoutDelegate) {
        super.init()
        self.delegate = delegate
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepare() {
        super.prepare()
        if collectionView?.numberOfSections != 2 {
            return
        }
        let left = CGFloat(0.0)
        let width = collectionView?.frame.size.width
        self.contentSize = CGSize(width: width!, height: contentHeight)
        attributes0 = Array<UICollectionViewLayoutAttributes>()
        attributes1 = Array<UICollectionViewLayoutAttributes>()
        guard let limit0 = collectionView?.numberOfItems(inSection: 0) else {
            return
        }
        for item in 0..<limit0 {
            let indexPath0 = IndexPath(item: item, section: 0)
            let attribute0 = UICollectionViewLayoutAttributes(forCellWith: indexPath0)
            let size = delegate.itemSize(layout: self, indexPath: indexPath0)
            let frame = CGRect(x: left, y: 0, width: width!, height: size.height)
            attribute0.frame = frame
            attribute0.zIndex = 9999 - (item+1)
            attribute0.alpha = item == 0 ? 1 : 0
            attribute0.transform = CGAffineTransform.identity
            self.attributes0.append(attribute0)
        }
        guard let limit = collectionView?.numberOfItems(inSection: 1) else {
            return
        }
        let _scaleXY = 1 - (width! - 20.auto()) / width!
        for item in 0..<min(limit, 8) {
            let indexPath = IndexPath(item: item, section: 1)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = delegate.itemSize(layout: self, indexPath: indexPath)
            let frame = CGRect(x: left, y: CGFloat((item+1)) * (itemSpacing - CGFloat(item) * 1), width: width!, height: size.height)
            attribute.frame = frame
            attribute.zIndex = 999 - (item+1)
            switch limit {
            case 1:
                attribute.alpha = 0
            case 2:
                switch item {
                case 0:
                    attribute.alpha = 0.7
                default:
                    attribute.alpha = 0
                }
            default:
                switch item {
                case 0:
                    attribute.alpha = 0.7
                case 1:
                    attribute.alpha = 0.4
                default:
                    attribute.alpha = 0
                }
            }
            let scale = 1.0 - (CGFloat((item+1)) * _scaleXY)
            attribute.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            self.attributes1.append(attribute)
        }
        if self.attributes1.count > 0 {
            let lastItemAttributes = self.attributes1.last
            let newHeight = (lastItemAttributes?.frame.origin.y)! + (lastItemAttributes?.frame.size.height)! + 20.auto()
            let newWidth = (self.collectionView?.frame.size.width)!
            self.contentSize = CGSize(width: newWidth, height: newHeight)
        }
    }
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
}
extension NotificationFoldLayout {
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        self.insertedIndexPaths = Array<IndexPath>()
        self.removedIndexPaths = Array<IndexPath>()
        updateItems.forEach { (updateItem) in
            if updateItem.updateAction == .insert {
                if updateItem.indexPathAfterUpdate?.item != nil , let indexPath = updateItem.indexPathAfterUpdate  {
                    self.insertedIndexPaths?.append(indexPath)
                }
            }else if updateItem.updateAction == .delete {
                if updateItem.indexPathBeforeUpdate?.item != nil , let indexPath = updateItem.indexPathBeforeUpdate  {
                    self.removedIndexPaths?.append(indexPath)
                }
            }
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in self.attributes0 {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        for attributes in self.attributes1 {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section == 0 {            return self.attributes0.get(indexPath.item)
        }
        return self.attributes1.get(indexPath.item)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let ucount = self.insertedIndexPaths?.count, (ucount>0)   {
            return true
        }
        return false
    }
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {        if self.insertedIndexPaths?.contains(itemIndexPath) ?? false , itemIndexPath.section == 0 {
        let attributes = self.attributes0[itemIndexPath.item]
        attributes.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1).translatedBy(x: 0, y: -140.auto())
        attributes.alpha = 0.0
        return attributes
    }else {
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.removedIndexPaths?.contains(itemIndexPath) ?? false , itemIndexPath.section == 0{
            let attributes = self.attributes0[itemIndexPath.item]
            attributes.alpha = 0.0
            attributes.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1).translatedBy(x: 0, y: -140.auto())
            return attributes
        }else {
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        }
    }
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.insertedIndexPaths = nil
        self.removedIndexPaths = nil
    }
}

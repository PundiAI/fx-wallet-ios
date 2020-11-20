
import Foundation
import UIKit
protocol NotificationLayoutDelegate:NSObjectProtocol {
    func itemSize(layout:UICollectionViewLayout,  indexPath:IndexPath) -> CGSize
}
class NotificationExpandLayout: UICollectionViewFlowLayout {
    private var delegate:NotificationLayoutDelegate!
    private var insertedIndexPaths:Array<IndexPath>?
    private var removedIndexPaths:Array<IndexPath>?       private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    private var visibleItemsSizeCache: [IndexPath:CGSize] = [:]
    private var visibleIndexPaths: Set<IndexPath> = Set()
    var attributes0  = Array<UICollectionViewLayoutAttributes>()
    var attributes1  = Array<UICollectionViewLayoutAttributes>()
    var contentSize: CGSize = CGSize(width: 0, height: 0)
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
        var top = CGFloat(0.0)
        let left = CGFloat(0.0)
        let width = collectionView?.frame.size.width
        attributes0 = Array<UICollectionViewLayoutAttributes>()
        attributes1 = Array<UICollectionViewLayoutAttributes>()
        guard let limit0 = collectionView?.numberOfItems(inSection: 0) else {
            return
        }
        let scaleXY = (collectionView!.bounds.width - 24.auto() * 2) / collectionView!.bounds.width
        for item in 0..<limit0 {
            let indexPath0 = IndexPath(item: item, section: 0)
            let attribute0 = UICollectionViewLayoutAttributes(forCellWith: indexPath0)
            let size0 = delegate.itemSize(layout: self, indexPath: indexPath0)
            let frame = CGRect(x: left, y: ceil(top + CGFloat(indexPath0.row * 0)), width: width!, height: size0.height)
            attribute0.frame = frame
            attribute0.zIndex = 9999
            attribute0.alpha = 0
            attribute0.transform = CGAffineTransform.identity.scaledBy(x: scaleXY, y: scaleXY)
            self.attributes0.append(attribute0)
        }
        guard let limit1 = collectionView?.numberOfItems(inSection: 1) else {
            return
        }
        for item in 0..<limit1 {
            let indexPath = IndexPath(item: item, section: 1)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)            let size = delegate.itemSize(layout: self, indexPath: indexPath)
            let frame = CGRect(x: left, y: ceil(top + CGFloat(indexPath.row * 0)), width: width!, height: size.height)
            attribute.frame = frame
            attribute.zIndex = 999 - (item+1)
            attribute.alpha = 1
            attribute.transform = CGAffineTransform.identity.scaledBy(x: scaleXY, y: scaleXY)
            self.attributes1.append(attribute)
            top += size.height
        }
        if self.attributes1.count > 0 {
            let lastItemAttributes = self.attributes1.last
            let newHeight = (lastItemAttributes?.frame.origin.y)! + (lastItemAttributes?.frame.size.height)!
            let newWidth = width!
            self.contentSize = CGSize(width: newWidth, height: max( newHeight + 40.auto(), ScreenHeight))
        }
    }
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

























}
extension NotificationExpandLayout {
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        self.insertedIndexPaths = Array<IndexPath>()
        self.removedIndexPaths = Array<IndexPath>()        updateItems.forEach { (updateItem) in
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
            if attributes.frame.intersects(rect) {                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section == 0 {
            return self.attributes0.get(indexPath.item)
        }
        return self.attributes1.get(indexPath.item)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let rcount = self.removedIndexPaths?.count, let icount = self.insertedIndexPaths?.count, (rcount>0 || icount>0)   {
            return true
        }
        return false
    }
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.insertedIndexPaths?.contains(itemIndexPath) ?? false {
            let attributes = self.attributes1[itemIndexPath.item]
            attributes.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            attributes.alpha = 0
            return attributes
        }else {
            return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        }
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if self.removedIndexPaths?.contains(itemIndexPath) ?? false {
            if let attributes = self.attributes1.get(itemIndexPath.row) {
                attributes.alpha = 0.0
                attributes.transform3D = CATransform3DMakeScale(0.5, 0.5, 1.0);
                return attributes
            }
        }
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.insertedIndexPaths = nil
        self.removedIndexPaths = nil
    }
}
extension NotificationExpandLayout {
    private func addItem(_ item: UICollectionViewLayoutAttributes, in view: UICollectionView) {
        let behavior = UIAttachmentBehavior(item: item, attachedToAnchor: floor(item.center))
        animator.addBehavior(behavior, 0.7, 1.5)
        visibleIndexPaths.insert(item.indexPath)
        visibleItemsSizeCache[item.indexPath] = item.bounds.size
    }
    private func addItem(_ item: UIDynamicItem, in view: UICollectionView) {
        guard let item = item as? UICollectionViewLayoutAttributes else {
            return
        }
        addItem(item, in: view)
    }
    private func update(behavior: UIAttachmentBehavior, and item: UIDynamicItem, in view: UICollectionView, for bounds: CGRect) {
        let delta = CGVector(dx: bounds.origin.x - view.bounds.origin.x, dy: bounds.origin.y - view.bounds.origin.y)
        let resistance = CGVector(dx: abs(view.panGestureRecognizer.location(in: view).x - behavior.anchorPoint.x) / 1000, dy: abs(view.panGestureRecognizer.location(in: view).y - behavior.anchorPoint.y) / 1000)
        item.center.y += delta.dy < 0 ? max(delta.dy, delta.dy * resistance.dy) : min(delta.dy, delta.dy * resistance.dy)
        item.center = floor(item.center)
    }
}
extension UIDynamicAnimator {
    open func addBehavior(_ behavior: UIAttachmentBehavior, _ damping: CGFloat, _ frequency: CGFloat) {
        behavior.damping = damping
        behavior.frequency = frequency
        addBehavior(behavior)
    }
}
fileprivate func floor(_ point: CGPoint) -> CGPoint {
    CGPoint(x: floor(point.x), y: floor(point.y))
}

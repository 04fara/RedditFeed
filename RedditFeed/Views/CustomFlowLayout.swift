//
//  CustomFlowLayout.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import UIKit

protocol CustomFlowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, scaleRatioForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CustomFlowLayout: UICollectionViewLayout {
    struct Const {
        static let numOfColumns: Int = 2
        static let itemSpacing: CGFloat = 8
    }

    weak var delegate: CustomFlowLayoutDelegate?

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        let insets: UIEdgeInsets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return .init(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        cache.removeAll()

        let itemWidth: CGFloat = contentWidth / CGFloat(Const.numOfColumns)

        var xOffset: [CGFloat] = .init(repeating: 0, count: Const.numOfColumns),
            yOffset: [CGFloat] = .init(repeating: 0, count: Const.numOfColumns)
        for i in 0..<Const.numOfColumns {
            xOffset[i] = CGFloat(i) * itemWidth
        }

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath: IndexPath = .init(item: item, section: 0)
            let itemHeight: CGFloat
            if let scaleRatio = delegate?.collectionView(collectionView, scaleRatioForItemAtIndexPath: indexPath) {
                itemHeight = scaleRatio * itemWidth + 2 * Const.itemSpacing
            } else {
                itemHeight = 180 + 2 * Const.itemSpacing
            }
            let column: Int = yOffset[0] <= yOffset[1] ? 0 : 1
            let frame: CGRect = .init(x: xOffset[column], y: yOffset[column], width: itemWidth, height: itemHeight)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] += itemHeight

            let itemAttributes: UICollectionViewLayoutAttributes = .init(forCellWith: indexPath)
            var insets: UIEdgeInsets = .init(top: Const.itemSpacing, left: Const.itemSpacing, bottom: Const.itemSpacing, right: Const.itemSpacing)
            insets.left *= column == 0 ? 0 : 1
            insets.right *= column == 0 ? 1 : 0
            itemAttributes.frame = frame.inset(by: insets)
            cache.append(itemAttributes)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let visible: [UICollectionViewLayoutAttributes] = cache.filter { $0.frame.intersects(rect) }

        return visible
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

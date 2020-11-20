//
//  ChatMessageSnapshotBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/16.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

protocol SnapshotProviderProtocol {
    func snapshot() -> (UIImageView, CGRect)?
    func snapshotText() -> String
}

extension ChatViewController {
    class SnapshotBinder {
        private lazy var view = SnapshotView(frame: ScreenBounds)
        private weak var snapshotIV: UIView?
        private var onClickCopy: (() -> Void)?
        private var onClickInfo: (() -> Void)?

        init() {
            weak var welf = self
            view.hideButton.action {
                welf?.hide()
            }
            view.copyButton.action {
                welf?.onClickCopy?()
                welf?.hide()
            }
            view.infoButton.action {
                welf?.onClickInfo?()
                welf?.hide()
            }
        }

        func show(snapshot: SnapshotProviderProtocol, inView container: UIView, onClickCopy: @escaping () -> Void,
                  onClickInfo: (() -> Void)?)
        {
            guard let (snapshotIV, recommendFrame) = snapshot.snapshot() else { return }

            self.snapshotIV = snapshotIV
            self.onClickCopy = onClickCopy
            self.onClickInfo = onClickInfo
            view.relayout(onClickInfo == nil)

            let margin: CGFloat = 18
            let actionSize = view.actionContainer.size

            let maxY = ScreenHeight - 44
            if snapshotIV.frame.maxY + margin + actionSize.height >= maxY {
                snapshotIV.frame.origin.y = maxY - actionSize.height - margin - recommendFrame.height
            }

            var recommendX = recommendFrame.minX
            if recommendX + actionSize.width >= ScreenWidth {
                recommendX = ScreenWidth - 14 - actionSize.width
            }

            var recommendY = snapshotIV.frame.maxY + 10
            if snapshotIV.height > recommendFrame.height {
                recommendY -= (snapshotIV.height - recommendFrame.height)
            }

            container.addSubview(view)
            view.addSubview(snapshotIV)

            view.frame = container.bounds
            view.actionContainer.origin = CGPoint(x: recommendX, y: recommendY)
            view.actionContainer.layer.add(animation(), forKey: "alert")
        }

        func hide() {
            snapshotIV?.removeFromSuperview()
            view.removeFromSuperview()
        }

        private func animation() -> CAKeyframeAnimation {
            let animation = CAKeyframeAnimation(keyPath: "transform")
            animation.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1)),
                                NSValue(caTransform3D: CATransform3DIdentity)]
            animation.duration = 0.2
            animation.keyTimes = [0.0, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut),
                                         CAMediaTimingFunction(name: .easeInEaseOut),
                                         CAMediaTimingFunction(name: .easeInEaseOut)]
            return animation
        }
    }
}

//
//  WalletProgressView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/12.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import pop
import UIKit
import WKKit

extension WalletViewController {
    class ProgressView: UIView, CAAnimationDelegate {
        private var dotView: UIView = {
            let v = UIView(HDA(0x00FFFE))
            v.layer.cornerRadius = 4
            v.layer.masksToBounds = true
            return v
        }()

        private var percentLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.text = "0%"
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        private var statusLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.text = TR("Wallet.Wait")
            v.textColor = UIColor.white.withAlphaComponent(0.3)
            v.backgroundColor = .clear
            return v
        }()

        private var backArcLayer = CAShapeLayer()
        private var foreArcLayer = CAShapeLayer()
        private var gradientContainerLayer = CALayer()
        private var leftGradientLayer = CAGradientLayer()
        private var rightGradientLayer = CAGradientLayer()
        private var scaleLayers: [CAShapeLayer] = []

        private var lineWidth: CGFloat = 5
        private var linePadding: CGFloat = 3
        private var startAngle: Double!
        private var endAngle: Double!
        private var radius: CGFloat!
        private var diameter: CGFloat!
        private var arcCenter: CGPoint!
        private var arcFrame: CGRect!

        private var endColor = HDA(0x00FFFE)
        private var midColor = HDA(0x03BCF1)
        private var startColor = HDA(0x0652DC)

        private let animationTag = "tag"
        private var animationProgress: CGFloat = 1

        private(set) var progress: CGFloat = 0.0
        private var animationDidEnd: (() -> Void)?

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            let size = min(frame.width, frame.height)
            super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: size, height: size))
            logWhenDeinit()

            configuration()
            layoutUI()
        }

        func reset() {
            removeAllAnimation()
            fillScales(endAngle: startAngle.f)

            progress = 0
            dotView.frame = CGRect(x: radius + 4, y: 4 + lineWidth, width: 8, height: 8)
            statusLabel.text = TR("Wallet.Wait")
            percentLabel.text = "0%"
            animationProgress = 1
            foreArcLayer.strokeEnd = 0
        }

        func set(progress: CGFloat, duration: TimeInterval = 1, completionHandler: (() -> Void)? = nil) {
            let progress = progress > 1 ? 1 : progress
            guard progress >= 0, progress != self.progress else { return }

            statusLabel.isHidden = false
            percentLabel.isHidden = false
            if progress == 0 {
                reset()
            } else {
                removeAllAnimation()

                let currentProgress = self.progress * animationProgress
                foreArcLayer.strokeEnd = currentProgress
                percentLabel.text = String(format: "%.1f", currentProgress * 100) + "%"
                statusLabel.text = TR("Wallet.Syncing")

                let currentAngle = currentProgress.d * Double.pi * 2
                let dotSize = dotView.height
                let dotPosition = point(of: currentAngle)
                dotView.frame = CGRect(x: dotPosition.x - dotSize * 0.5, y: dotPosition.y - dotSize * 0.5, width: dotSize, height: dotSize)

                self.progress = progress
                animationDidEnd = completionHandler

                let endAngle = CGFloat(2 * Double.pi * progress.d + startAngle)
                fillScales(endAngle: endAngle)

                let dotAnimation = self.dotAnimation(startAngle: CGFloat(currentAngle + startAngle), endAngle: endAngle, duration: duration)
                dotView.layer.add(dotAnimation, forKey: animationTag)
                percentLabel.pop_add(percentAnimation(from: currentProgress, to: progress, duration: duration), forKey: animationTag)
                foreArcLayer.add(arcAnimation(from: currentProgress, to: progress, duration: duration), forKey: animationTag)
            }
        }

        func set(startColor: UIColor? = nil, midColor: UIColor? = nil, endColor: UIColor? = nil, backArcColor: UIColor? = nil) {
            if let color = midColor { self.midColor = color }
            if let color = endColor { self.endColor = color }
            if let color = startColor { self.startColor = color }
            leftGradientLayer.colors = [self.midColor.cgColor, self.endColor.cgColor]
            rightGradientLayer.colors = [self.startColor.cgColor, self.midColor.cgColor]

            if let color = backArcColor { backArcLayer.strokeColor = color.cgColor }
        }

        func set(lineWidth: CGFloat) {
            self.lineWidth = lineWidth

            backArcLayer.lineWidth = lineWidth - linePadding
            foreArcLayer.lineWidth = lineWidth
        }

        // MARK: Animation

        internal func animationDidStop(_: CAAnimation, finished flag: Bool) {
            if !flag { return }

            foreArcLayer.strokeEnd = progress > 1 ? 1 : progress
            foreArcLayer.removeAnimation(forKey: animationTag)
            animationDidEnd?()
        }

        fileprivate func removeAllAnimation() {
            foreArcLayer.removeAnimation(forKey: animationTag)
            dotView.layer.removeAnimation(forKey: animationTag)
            percentLabel.pop_removeAnimation(forKey: animationTag)
        }

        fileprivate func arcAnimation(from _: CGFloat = 0, to: CGFloat, duration: TimeInterval) -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = to
            animation.duration = duration
            animation.fillMode = .forwards
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.isRemovedOnCompletion = false
            return animation
        }

        fileprivate func dotAnimation(startAngle: CGFloat, endAngle: CGFloat, duration: TimeInterval) -> CAKeyframeAnimation {
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.duration = duration
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.calculationMode = .paced
            animation.isRemovedOnCompletion = false
            animation.path = UIBezierPath(arcCenter: arcCenter, radius: radius - 4.5, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
            return animation
        }

        fileprivate func percentAnimation(from: CGFloat = 0, to: CGFloat, duration: TimeInterval) -> POPBasicAnimation {
            let tag = animationTag
            let animation = POPBasicAnimation()
            animation.duration = duration
            animation.toValue = to
            animation.fromValue = from
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.property = POPAnimatableProperty.property(withName: "") { [weak self] p in
                guard let property = p else { return }

                property.threshold = 0.025
                property.writeBlock = { obj, values in
                    guard let label = obj as? UILabel, let values = values else { return }

                    self?.animationProgress = values[0] / to
                    label.text = String(format: "%.1f", values[0] * 100) + "%"
                    if values[0] >= to {
                        label.pop_removeAnimation(forKey: tag)
                        self?.animationProgress = 1
                        self?.statusLabel.isHidden = true
                        self?.percentLabel.isHidden = true
                    }
                }
            } as? POPAnimatableProperty
            return animation
        }

        // MARK: Utils

        private func configuration() {
            endAngle = 1.5 * Double.pi
            startAngle = -0.5 * Double.pi

            radius = min(height, width) * 0.5 - 8
            diameter = radius * 2

            arcFrame = CGRect(x: (width - diameter) * 0.5,
                              y: (height - diameter) * 0.5,
                              width: diameter,
                              height: diameter)
            arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)

            foreArcLayer.strokeEnd = 0
        }

        private func layoutUI() {
            gradientContainerLayer.addSublayer(leftGradientLayer)
            gradientContainerLayer.addSublayer(rightGradientLayer)
            gradientContainerLayer.mask = foreArcLayer
            backArcLayer.addSublayer(gradientContainerLayer)
            layer.addSublayer(backArcLayer)

            backArcLayer.bounds = arcFrame
            backArcLayer.position = arcCenter
            backArcLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius - lineWidth, startAngle: startAngle.f, endAngle: endAngle.f, clockwise: true).cgPath
            backArcLayer.fillColor = UIColor.clear.cgColor
            backArcLayer.lineWidth = lineWidth - linePadding
            backArcLayer.strokeColor = UIColor.white.cgColor
            backArcLayer.backgroundColor = UIColor.clear.cgColor
            backArcLayer.shadowColor = HDA(0x0652DC).cgColor
            backArcLayer.shadowRadius = 15
            backArcLayer.shadowOpacity = 0.8
            backArcLayer.shadowOffset = .zero

            foreArcLayer.path = backArcLayer.path!
            foreArcLayer.bounds = arcFrame
            foreArcLayer.position = arcCenter
            foreArcLayer.fillColor = UIColor.clear.cgColor
            foreArcLayer.lineWidth = lineWidth
            foreArcLayer.strokeColor = UIColor.white.cgColor
            foreArcLayer.backgroundColor = UIColor.clear.cgColor

            //            leftGradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
            //            leftGradientLayer.startPoint = CGPoint(x: 0, y: 1)
            //            leftGradientLayer.endPoint = CGPoint(x: 0, y: 0)
            //            leftGradientLayer.colors = [midColor.cgColor, endColor.cgColor]
            //
            //            rightGradientLayer.frame = CGRect(x: width * 0.5, y: 0, width: width, height: height)
            //            rightGradientLayer.startPoint = CGPoint(x: 0, y: 0)
            //            rightGradientLayer.endPoint = CGPoint(x: 0, y: 1)
            //            rightGradientLayer.colors = [startColor.cgColor, midColor.cgColor]

            rightGradientLayer.isHidden = true
            leftGradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
            leftGradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
            leftGradientLayer.endPoint = CGPoint(x: 1, y: 1)
            leftGradientLayer.colors = [endColor.cgColor, startColor.cgColor]

            gradientContainerLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
            gradientContainerLayer.backgroundColor = UIColor.clear.cgColor

            layoutScales()

            addSubview(dotView)
            dotView.frame = CGRect(x: radius + 4, y: 4 + lineWidth, width: 8, height: 8)

            addSubviews([percentLabel, statusLabel])
            percentLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-6)
                make.height.equalTo(30)
            }

            statusLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(percentLabel.snp.bottom).offset(3)
                make.height.equalTo(20)
            }
        }

        private func layoutScales() {
            let perAngle = Double.pi * 2 / 12 / 5
            let scaleWidth = perAngle / 10.0
            let shortLineWidth: CGFloat = 0.5
            let longLineWidth: CGFloat = 2.5
            for index in 0 ..< 60 {
                let startAngle = self.startAngle + perAngle * index.d
                let endAngle = startAngle + scaleWidth

                let shortScale = CAShapeLayer()
                shortScale.strokeColor = HDA(0x999999).cgColor
                shortScale.lineWidth = shortLineWidth
                shortScale.path = UIBezierPath(arcCenter: center, radius: radius - shortLineWidth, startAngle: startAngle.f, endAngle: endAngle.f, clockwise: true).cgPath

                if index % 5 == 0 {
                    let longScale = CAShapeLayer()
                    longScale.path = UIBezierPath(arcCenter: center, radius: radius - shortLineWidth + 2 + longLineWidth, startAngle: startAngle.f, endAngle: endAngle.f, clockwise: true).cgPath
                    longScale.strokeColor = UIColor.white.cgColor
                    longScale.lineWidth = longLineWidth
                    layer.addSublayer(longScale)
                    scaleLayers.append(longScale)
                }

                layer.addSublayer(shortScale)
            }
        }

        fileprivate func fillScales(endAngle: CGFloat) {
            let perAngle = Double.pi * 2 / 12
            for (idx, scaleLayer) in scaleLayers.enumerated() {
                let layerAngle = startAngle + perAngle * idx.d
                scaleLayer.strokeColor = layerAngle >= endAngle.d ? UIColor.white.cgColor : HDA(0x1A7CEB).cgColor
            }
        }

        private func point(of angle: Double) -> CGPoint {
            let x: Float
            let y: Float
            let radius = self.radius - lineWidth
            let quadrant = angle / (Double.pi * 2)
            if quadrant <= 0.25 {
                x = Float(radius) * cosf(Float(Double.pi * 0.5 - angle))
                y = -Float(radius) * sinf(Float(Double.pi * 0.5 - angle))
            } else if quadrant <= 0.5 {
                x = Float(radius) * cosf(Float(angle - Double.pi * 0.5))
                y = Float(radius) * sinf(Float(angle - Double.pi * 0.5))
            } else if quadrant <= 0.75 {
                x = -Float(radius) * cosf(Float(Double.pi * 1.5 - angle))
                y = Float(radius) * sinf(Float(Double.pi * 1.5 - angle))
            } else {
                x = -Float(radius) * cosf(Float(angle - Double.pi * 1.5))
                y = -Float(radius) * sinf(Float(angle - Double.pi * 1.5))
            }
            return CGPoint(x: arcCenter.x + CGFloat(x), y: arcCenter.y + CGFloat(y))
        }
    }
}

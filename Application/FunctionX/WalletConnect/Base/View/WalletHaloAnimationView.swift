//
//  WalletHaloAnimationView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/13.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import pop

fileprivate let radius: CGFloat = 49
fileprivate let diameter: CGFloat = 49 * 2
fileprivate let viewSize: CGFloat = 195

class WalletHaloAnimationView: UIView {
    
    fileprivate var circleLayer1: CAShapeLayer!
    fileprivate var circleLayer2: CAShapeLayer!
    fileprivate var circleLayer3: CAShapeLayer!
    fileprivate var circleLayer4: CAShapeLayer!

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: viewSize, height: viewSize))
        logWhenDeinit()
        
        configuration()
        layoutUI()
    }
    
    func startAnimation() {

        startPositionAnimation(layer: circleLayer1, offset1: CGPoint(x: 21, y: 56), offset2: CGPoint(x: 50.5, y: -0.5))
        startPositionAnimation(layer: circleLayer2, offset1: CGPoint(x: -40, y: -5), offset2: CGPoint(x: -41, y: 40))
        startPositionAnimation(layer: circleLayer3, offset1: CGPoint(x: 50, y: -6), offset2: CGPoint(x: 33, y: -39))
        startPositionAnimation(layer: circleLayer4, offset1: CGPoint(x: -72, y: -13), offset2: CGPoint(x: -54, y: -42))
    }
                          
    fileprivate func startPositionAnimation(layer: CALayer, offset1: CGPoint, offset2: CGPoint) {
        
        let path = CGMutablePath()
        let startPoint = layer.position
        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: startPoint.x + offset1.x, y: startPoint.y + offset1.y))
        path.addLine(to: CGPoint(x: startPoint.x + offset2.x, y: startPoint.y + offset2.y))
        path.closeSubpath()
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 3.5
        animation.fillMode = .forwards
        animation.calculationMode = .cubic
        animation.isRemovedOnCompletion = false
        animation.repeatCount = 10000
        animation.path = path
        layer.removeAnimation(forKey: "tag")
        layer.add(animation, forKey: "tag") 
    }
    
    //MARK: Utils
    fileprivate func configuration() {
        backgroundColor = .clear
    }
    
    fileprivate func layoutUI() {
        
        let circleBounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circleLayer1 = circle(bounds: circleBounds,
                              position: CGPoint(x: 4 + radius, y: 32 + radius),
                              fillColor: HDA(0x1BE2FF))
        layer.addSublayer(circleLayer1)
        
        circleLayer2 = circle(bounds: circleBounds,
                              position: CGPoint(x: 75 + radius, y: 28 + radius),
                              fillColor: HDA(0xFF1BF9))
        layer.addSublayer(circleLayer2)
        
        circleLayer3 = circle(bounds: circleBounds,
                              position: CGPoint(x: 24 + radius, y: 70 + radius),
                              fillColor: HDA(0xFF8A00))
        layer.addSublayer(circleLayer3)
        
        circleLayer4 = circle(bounds: circleBounds,
                              position: CGPoint(x: 80 + radius, y: 85 + radius),
                              fillColor: HDA(0xA3FF54))
        layer.addSublayer(circleLayer4)
        
        let coverLayer = circle(bounds: self.bounds, position: self.center, fillColor: UIColor.black)
        layer.addSublayer(coverLayer)
    }
    
    fileprivate func circle(bounds: CGRect, position: CGPoint, fillColor: UIColor) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.bounds = bounds
        layer.position = position
        layer.path = UIBezierPath(ovalIn: bounds).cgPath
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = 0
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = fillColor.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        return layer
    }
}











class WalletLaunchHaloAnimationView: WalletHaloAnimationView {
    
    var endScaleAnimationHandler: (() -> Void)?
    
    override func startAnimation() {}
    func startPositionAnimation() {
        super.startAnimation()
    }
    
    func startScaleAnimation() {
        
        startScaleAnimation(circleLayer1)
        startScaleAnimation(circleLayer2)
        startScaleAnimation(circleLayer3)
        startScaleAnimation(circleLayer4) 
        
    }
    
    fileprivate func startScaleAnimation(_ layer: CALayer) {
        
        let toValue = radius * 0.65
        let scaleAnimation = POPBasicAnimation()
        scaleAnimation.duration = 1.5
        scaleAnimation.toValue = toValue
        scaleAnimation.fromValue = radius * 1.5
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        scaleAnimation.property = POPAnimatableProperty.property(withName: "") { [weak self](p) in
            guard let property = p else { return }

            property.threshold = 0.1
            property.writeBlock = { (obj, values) in
                guard let layer = obj as? CALayer, let values = values else { return }
                layer.shadowRadius = values[0]

                if layer.shadowRadius <= toValue {
                    layer.pop_removeAnimation(forKey: "tag")
                    self?.didEndScaleAnimation()
                }
            }
        } as? POPAnimatableProperty
        layer.pop_add(scaleAnimation, forKey: "tag")
    }

    fileprivate func didEndScaleAnimation() {
        
        circleLayer1.shadowOpacity = 0.8
        circleLayer2.shadowOpacity = 0.8
        circleLayer3.shadowOpacity = 0.8
        circleLayer4.shadowOpacity = 0.8
        endScaleAnimationHandler?()
    }

    fileprivate override func circle(bounds: CGRect, position: CGPoint, fillColor: UIColor) -> CAShapeLayer {
        let layer = super.circle(bounds: bounds, position: position, fillColor: fillColor)
        layer.shadowRadius = radius * 1.5
        layer.shadowOpacity = 1
        return layer
    }
}

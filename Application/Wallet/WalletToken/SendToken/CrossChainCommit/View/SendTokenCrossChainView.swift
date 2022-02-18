//
//  SendTokenCrossChainView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenCrossChainCommitController {
    
    class View: BaseView {
        
        lazy var navTitleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        lazy var navSubtitleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: .white)
        lazy var bridgeFeeTip = TipView(frame: ScreenBounds)
        
        lazy var cancelButton: UIButton = {
            let v = UIButton()
            v.title = TR("Cancel")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = .white
            v.autoCornerRadius = 25
            v.backgroundColor = HDA(0x31324A)
            return v
        }()

        lazy var confirmButton: UIButton = {
            let v = UIButton()
            v.title = TR("Confirm")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = HDA(0x080A32)
            v.autoCornerRadius = 25
            v.backgroundColor = .white
            return v
        }()

        override func configuration() {
            super.configuration()
            
            contentView.autoCornerRadius = 36
            
            closeButton.autoCornerRadius = 16
            closeButton.image = IMG("SendToken.CrossChain")
            closeButton.backgroundColor = .white
            closeButton.contentVerticalAlignment = .center
            closeButton.contentHorizontalAlignment = .center
            closeButton.isUserInteractionEnabled = false
            closeButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9).auto()
            
            navBar.alpha = 0
            navBar.blur.isHidden = false
            navBar.blurColor.alpha = 0.54
            navBar.blurColor.backgroundColor = HDA(0x000237)
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            contentView.addView(cancelButton, confirmButton)
            
            navBar.navigationArea.addSubviews([navTitleLabel, navSubtitleLabel])
            closeButton.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            navTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(14.auto())
                make.left.equalTo(closeButton.snp.right).offset(16.auto())
                make.height.equalTo(20.auto())
            }
            
            navSubtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(navTitleLabel.snp.bottom).offset(2)
                make.left.equalTo(closeButton.snp.right).offset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            let edge = 24.auto()
            listView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(cancelButton.snp.top).offset(-edge)
            }
            
            cancelButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-edge)
                make.left.equalTo(24.auto())
                make.right.equalTo(confirmButton.snp.left).offset(-19.auto())
                make.height.equalTo(50.auto())
            }

            confirmButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-edge)
                make.left.equalTo(cancelButton.snp.right).offset(19.auto())
                make.right.equalTo(-24.auto())
                make.width.equalTo(cancelButton)
                make.height.equalTo(50.auto())
            }
        }
    }
}

extension SendTokenCrossChainCommitController {
    
    class TitleCell: FxTableViewCell {
        
        lazy var resultIV = UIImageView(image: IMG("SendToken.CrossChain"))
        lazy var resultIVBackground = UIView(.white, cornerRadius: 28)
        
        lazy var titleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 24, weight: .bold), alignment: .center)
        lazy var descLabel = UILabel(text: TR("CrossChain.F2E.TransferTip"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            let descHeight = TR("CrossChain.F2E.TransferTip").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 175.auto() + descHeight
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([resultIVBackground, resultIV, titleLabel, descLabel])
            
            resultIVBackground.snp.makeConstraints { (make) in
                make.top.equalTo(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            resultIV.snp.makeConstraints { (make) in
                make.center.equalTo(resultIVBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(resultIVBackground.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(30.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension SendTokenCrossChainCommitController {
    
    class SectionTitleCell: FxTableViewCell {
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: .white)
        lazy var chainTypeButton = ChainTypeButton().then{ $0.style = .lightContent }
        
        override class func height(model: Any?) -> CGFloat { (18 + 8).auto() }
        
        override func layoutUI() {
            
            addSubviews([titleLabel, chainTypeButton])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(18.auto())
            }
            
            chainTypeButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(12.auto())
                make.height.equalTo(16.auto())
            }
        }
    }
}

extension SendTokenCrossChainCommitController {
    
    class ImageInfoCell: WKTableViewCell.InfoCell {
        
        lazy var imageIV = UIImageView(image: IMG("Wallet.Settings"))
        
        override func layoutUI() {
            super.layoutUI()
            
            background.addSubview(imageIV)
            
            contentLabel.snp.updateConstraints { (make) in
                make.right.equalTo(-48.auto())
            }
            
            imageIV.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.right.equalTo(-16.auto())
                make.size.equalTo(CGSize(width: 20, height: 20).auto())
            }
        }
    }
    
    class BridgeFeeCell: ImageInfoCell {
        
        lazy var tipIV = UIImageView(image: IMG("ic_warning_white"))
        lazy var tipButton = UIButton(.clear)
        
        override func layoutUI() {
            super.layoutUI()
            
            tipIV.alpha = 0.5
            background.addSubviews([tipIV, tipButton])
            
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(16.auto())
                make.height.equalTo(36.auto())
            }
            
            contentLabel.snp.updateConstraints { (make) in
                make.right.equalTo(-48.auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(2.auto())
                make.left.equalTo(titleLabel)
                make.size.equalTo(CGSize(width: 16, height: 16).auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.top.left.equalTo(tipIV)
                make.size.equalTo(CGSize(width: 30, height: 30).auto())
            }
        }
    }
}


extension SendTokenCrossChainCommitController {
    class TipView: UIView {
        
        lazy var contentView = UIView(.clear)
        lazy var bgIV = UIImageView(image: IMG("CrossChain.bubble"))
        lazy var textLabel = UILabel(text: TR("CrossChain.BridgeFeeTip"), font: XWallet.Font(ofSize: 14), textColor: .white, lines: 0)
        
        var onHide: (() -> ())?
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.hide()
            self.onHide?()
        }
        
        private func configuration() {
            backgroundColor = .clear
            contentView.isUserInteractionEnabled = false
            bgIV.image = bgIV.image?.resizableImage(withCapInsets: UIEdgeInsets(top: 32, left: 60, bottom: 32, right: 60))
        }
        
        let bubbleEdge = UIEdgeInsets(top: 6, left: 8, bottom: 13, right: 8)
        let bubbleWidth: CGFloat = ScreenWidth - (40 * 2).auto()
        private func layoutUI() {
            addSubview(contentView)
            contentView.addSubviews([bgIV, textLabel])
            
            let edges = UIEdgeInsets(top: bubbleEdge.top + 10.auto(), left: bubbleEdge.left + 12.auto(), bottom: bubbleEdge.bottom + 10.auto(), right: bubbleEdge.right + 12.auto())
            let textHeight = TR("CrossChain.BridgeFeeTip").height(ofWidth: bubbleWidth - edges.left * 2, attributes: [.font: XWallet.Font(ofSize: 14.auto())])
            contentView.frame = CGRect(x: 24, y: 0, width: bubbleWidth, height: textHeight + edges.top + edges.bottom)
            bgIV.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.top.equalTo(edges.top)
                make.left.right.equalToSuperview().inset(edges.left)
            }
        }
        
        func show(in controller: UIViewController, at anchorView: UIView) {
            guard let supview = controller.view else { return }
            
            supview.addSubview(self)
            self.frame = CGRect(x: 0, y: 0, width: supview.width, height: supview.height)
            let anchorFrame = supview.convert(anchorView.frame, from: anchorView.superview)
            
            let triangleX: CGFloat = 40
            contentView.origin = CGPoint(x: anchorFrame.midX - triangleX, y: anchorFrame.minY - contentView.height + 8)
            let animation = CAKeyframeAnimation(keyPath: "transform")
            animation.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 0.01)),
                                NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
                                NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
                                NSValue(caTransform3D: CATransform3DIdentity)]
            animation.duration = 0.3
            animation.keyTimes = [0.0, 0.5, 0.75, 1.0]
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                         CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                         CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
            contentView.layer.removeAnimation(forKey: "alert")
            contentView.layer.add(animation, forKey: "alert")

            self.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.isUserInteractionEnabled = true
            }
        }
        
        func hide() {
            self.removeFromSuperview()
        }
    }
}

//
//  FxCloudCreateValidatorView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxCloudCreateValidatorViewController {
    func addShadow() {
        
        let v = CAGradientLayer()
        v.frame = CGRect(x: 0, y: ScreenHeight - 154, width: ScreenWidth, height: 154)
        v.endPoint = CGPoint(x:0.5, y:1)
        v.startPoint = CGPoint(x:0.5, y:0)
        v.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.view.layer.insertSublayer(v, below: wk.view.confirmButton.layer)
    }
}

extension FxCloudCreateValidatorViewController {
    
    class InfoCellViewModel: WKTableViewCell.InfoCellViewModel {
        
        override var textWidth: CGFloat { ScreenWidth - 18 - 180 }
    }
    
    class InfoCell: WKTableViewCell.InfoCell {
        
        override class func height(model: Any?) -> CGFloat {
            return max(48, (model as? InfoCellViewModel)?.height ?? 0)
        }
        
        override func bind(_ viewModel: Any?) {
            super.bind(viewModel)
            guard let vm = viewModel as? InfoCellViewModel else { return }
            
            if vm.content.string.count > 20 {
                contentLabel.snp.updateConstraints { (make) in
                    make.top.equalTo(8)
                }
            }
        }
        
        private lazy var line = UIView(HDA(0x373737))
        
        override func layoutUI() {
            addSubviews([line, titleLabel, contentLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(18)
            }
            
            contentLabel.textAlignment = .right
            contentLabel.snp.updateConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(180)
                make.right.equalTo(-18)
            }
            
            line.snp.makeConstraints { (make) in
                make.bottom.equalTo(-0.75)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(0.75)
            }
        }
    }
}



extension FxCloudCreateValidatorViewController {

    class DescCell: WKTableViewCell.DescCell {
        override func layoutUI() {
            super.layoutUI()
            
            titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(18)
            }
            
            contentLabel.snp.updateConstraints { (make) in
                make.left.equalTo(18)
                make.right.equalTo(-18)
            }
        }
    }
}



extension FxCloudCreateValidatorViewController {
    
    class HeaderCell: WKTableViewCell {
        
        lazy var contentLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .bold)
            v.textColor = HDA(0x2D90FF)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.cornerRadius = 4
            v.clipsToBounds = true
            v.layer.borderColor = HDA(0x2D90FF).cgColor
            v.layer.borderWidth = 1
            
            let text = "  \(TR("CreateValidator.Header")) ."
            let attText = NSMutableAttributedString(string: text)
            attText.addAttributes([.foregroundColor: v.backgroundColor!], range: NSMakeRange(text.count - 1, 1))
            v.attributedText = attText
            return v
        }()
        
        override func initSubView() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
            
            self.contentView.addSubview(contentLabel)
            contentLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(18)
                make.height.equalTo(22)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { return 75 }
    }
}




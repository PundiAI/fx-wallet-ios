//
//
//  XWallet
//
//  Created by May on 2020/12/22.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension AdvancedSettingViewController {
    
    
    class MarkSlider: UISlider {
        
        var markPositions:[CGFloat] = []
        var markColor: UIColor?
        var markWidth: CGFloat?
        var leftBarColor: UIColor?
        var rightBarColor:UIColor?
        var barHeight: CGFloat?
         
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.markColor = UIColor(red: 106/255.0, green: 106/255.0, blue: 124/255.0,
                                     alpha: 0.7)
            self.markPositions = [10,20,30,40,50,60,70,80,90]
            self.markWidth = 1.0
            self.leftBarColor = UIColor(red: 55/255.0, green: 55/255.0, blue: 94/255.0,
                                        alpha: 0.8)
            self.rightBarColor = UIColor(red: 179/255.0, green: 179/255.0, blue: 193/255.0,
                                         alpha: 0.8)
            self.barHeight = 12
        }
         
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
         
         
        override func draw(_ rect: CGRect) {
            super.draw(rect)
     
            let leftTrackImage = createTrackImage(rect: rect, barColor: self.leftBarColor!)
                .resizableImage(withCapInsets: .zero)
             
            let rightTrackImage = createTrackImage(rect: rect, barColor: self.rightBarColor!)
             
            self.setMinimumTrackImage(leftTrackImage, for: .normal)
            self.setMaximumTrackImage(rightTrackImage, for: .normal)
        }
         

        func createTrackImage(rect: CGRect, barColor:UIColor) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            let context: CGContext = UIGraphicsGetCurrentContext()!
             
            context.setLineCap(.round)
            context.setLineWidth(self.barHeight!)
            context.move(to: CGPoint(x:self.barHeight!/2, y:rect.height/2))
            context.addLine(to: CGPoint(x:rect.width-self.barHeight!/2, y:rect.height/2))
            context.setStrokeColor(barColor.cgColor)
            context.strokePath()
             
            for i in 0..<self.markPositions.count {
                context.setLineWidth(self.markWidth!)
                let position: CGFloat = self.markPositions[i]*rect.width/100.0
                context.move(to: CGPoint(x:position, y: rect.height/2-self.barHeight!/2+1))
                context.addLine(to: CGPoint(x:position, y:rect.height/2+self.barHeight!/2-1))
                context.setStrokeColor(self.markColor!.cgColor)
                context.strokePath()
            }
             
            let trackImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return trackImage
        }
    }
    
    class PannelView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("Max.Slippage"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
            v.autoFont = true
            v.textAlignment = .left
            return v
        }()
        
        lazy var amountLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 16), textColor: COLOR.title)
            v.autoFont = true
            v.textAlignment = .right
            return v
        }()
        
        lazy var sliderView: MarkSlider = {
            let v = MarkSlider()
            v.leftBarColor = COLOR.title
            v.rightBarColor = COLOR.title.withAlphaComponent(0.05)
            v.barHeight = 8.auto()
            v.markPositions = []
            return v
        }()
        
        
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = COLOR.settingbc
            autoCornerRadius = 16
        }
        
        private func layoutUI() {
           addSubviews([titleLabel, amountLabel, sliderView])
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.height.equalTo(20.auto())
                make.top.equalTo(27.auto())
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(20.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            
            sliderView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(8.auto())
            }
        }
        
        static let  contentHeight: CGFloat = 108.auto()
    }
    
    
    class View: UIView {
        
        lazy var saveBtn = UIButton().doNormal(title: TR("Button.Save"))
        
        lazy var pannel: PannelView = {
            let v = PannelView(frame: CGRect.zero)
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            
            saveBtn.autoCornerRadius = 28
            saveBtn.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            saveBtn.titleLabel?.autoFont = true
        }
        
        private func layoutUI() {
            
            addSubview(pannel)
            
            pannel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(PannelView.contentHeight)
                make.top.equalTo(FullNavBarHeight + 8.auto())
            }
            
            addSubview(saveBtn)
            saveBtn.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}
        

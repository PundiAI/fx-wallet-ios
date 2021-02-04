//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension ImportWalletViewController {
    
    class ContentTextField: UITextField {
        let contentInsetLeft: CGFloat = 24
        private func topInset(forBounds: CGRect) ->CGFloat {
            return (forBounds.height - (self.font?.lineHeight ?? 0)) / 2.0
        }
        override func textRect(forBounds: CGRect) -> CGRect {
            return forBounds.insetBy(dx: contentInsetLeft , dy: topInset(forBounds: forBounds))
        }
        override func editingRect(forBounds: CGRect) -> CGRect {
            return forBounds.insetBy(dx: contentInsetLeft , dy: topInset(forBounds: forBounds))
        }
        override func placeholderRect(forBounds: CGRect) -> CGRect {
            return forBounds.insetBy(dx: contentInsetLeft, dy: topInset(forBounds: forBounds))
        }
    }
    
    
    class EditView: UIView, UITextFieldDelegate {
        
        lazy var backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
            $0.backgroundColor = HDA(0xF4F4F4).withAlphaComponent(0.88)
        }
        
        lazy var inputTFContainer:FxCustomRoundTextField = {
            let container = FxCustomRoundTextField(textField: self.inputTF)
            container.backgroundColor = COLOR.inputbg
            container.borderColor = COLOR.inputborder
            container.borderWidth = 2
            container.autoCornerRadius = 28
            return container
        }()
        
        lazy var inputTF: UITextField = {
            let textField = ContentTextField()
            
            textField.textColor = UIColor.black
            textField.font = XWallet.Font(ofSize: 16, weight: .bold)
            textField.autoFont = true
            textField.returnKeyType = .done
            textField.tintColor = COLOR.inputborder
            textField.delegate  = self
//            textField.backgroundColor = UIColor.green
            textField.contentVerticalAlignment = .fill
            textField.contentHorizontalAlignment = .left
            textField.textAlignment = .left
            
            return textField
        }()
        
        lazy var touchControl = UIControl()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        var completed:((String?)->())?
        
        var gframe:CGRect = .zero {
            didSet {
                inputTFContainer.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(gframe.minX.auto())
                    make.top.equalToSuperview().offset(gframe.minY.auto())
                    make.width.equalTo(gframe.width)
                    make.height.equalTo(56.auto())
                }
            }
        }
        
        private func configuration() {
            backgroundColor = .clear
            touchControl.action { [weak self] in
                self?.completed?(nil)
                self?.removeFromSuperview()
            }
            
//            inputTF.rx.text.distinctUntilChanged()
//                .map { (text) -> String in
//                    var  ntext = text ?? "?"
//                    ntext = ntext.trimmingCharacters(in: .whitespaces).trimCenterSpace()
//                    return ntext
//            }
//            .subscribeOn(MainScheduler.instance)
//            .map {[weak self] (text) -> CGFloat in
//                guard let this = self else { return 0 }
//                this.inputTF.text = text
//                this.inputTF.sizeToFit()
//                return this.inputTF.width
//            }.subscribe(onNext: {[weak self] (containerWidth) in
//                guard let this = self else { return}
//                if this.gframe != .zero && (containerWidth + this.gframe.minX ) < ScreenWidth - (24 * 2).auto()  {
//                    this.inputTFContainer.snp.remakeConstraints { (make) in
//                        make.left.equalToSuperview().offset(this.gframe.minX)
//                        make.top.equalToSuperview().offset(this.gframe.minY)
//                        make.width.equalTo(max(containerWidth, 56.auto()))
//                        make.height.equalTo(56.auto())
//                    }
//                }
//            }).disposed(by: defaultBag)
        }
        
        private func layoutUI() {
            
            //            backgroundBlur.isHidden = true
            
            addSubviews([backgroundBlur, touchControl, inputTFContainer])
            backgroundBlur.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            touchControl.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            inputTFContainer.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().offset(gframe.minX.auto())
//                make.top.equalToSuperview().offset(gframe.minY.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview().offset(130.auto())
//                make.width.equalTo(gframe.width)
                make.height.equalTo(56.auto())
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            var pwd = textField.text!.trimmingCharacters(in: .whitespaces)
            pwd = pwd.trimCenterSpace().lowercased()
            self.completed?(pwd)
            self.removeFromSuperview()
            return false
        }
        
    }
}

extension ImportWalletViewController {
    
    class View: UIView, UITextFieldDelegate {
        
        static let MIN_HEIHGT: CGFloat = ScreenHeight >= 750 ? 240.auto() : 140.auto()
        
        var contentSize: CGSize { CGSize(width: ScreenWidth, height: ScreenHeight * 1.5 )}
        
        class NTipView: TipView {
            var selectedSubject: BehaviorRelay<Bool> = BehaviorRelay(value:false)
            
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                textLabel.font = XWallet.Font(ofSize: 14)
                textLabel.autoFont = true
                textLabel.textColor = COLOR.tip
                textLabel.numberOfLines = 0
                dotView.backgroundColor = COLOR.tip
                dotView.autoCornerRadius = 3
                
                dotView.snp.remakeConstraints { (make) in
                    make.top.equalTo(textLabel.snp.top).offset(7.auto())
                    make.left.equalToSuperview()
                    make.size.equalTo(CGSize(width: 6, height: 6).auto())
                }
                
                selectedSubject.map { (value) -> UIColor in
                    return value ? COLOR.tipselected : COLOR.tip
                }.subscribe(onNext: {[weak self] (color) in
                    self?.textLabel.textColor = color
                    self?.dotView.backgroundColor = color
                }).disposed(by: defaultBag)
            }
        }
        
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        
        var contentView: UIScrollView = {
            let v = UIScrollView(.clear)
            v.contentSize = CGSize(width: 0, height: 820.auto())
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            return v
        } ()
        
        var realview = UIView()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(frame: CGRect(x: 24.auto(), y: FullNavBarHeight, width: 200, height: 58))
            v.text = TR("Import.Title")
            v.font = XWallet.Font(ofSize: 40, weight: .bold)
            v.autoFont = true
            v.sizeToFit()
            v.textColor = COLOR.title
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var subtitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Import.SubTitle")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var tagList: VITagListView = {
            let v = VITagListView(frame: ScreenBounds)
            v.minHeight = ImportWalletViewController.View.MIN_HEIHGT
            return v
        }()
        
        
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        var editView: EditView?
        
        var tagHeightChangeSubject: BehaviorRelay<(VITagListView, CGFloat)?> = BehaviorRelay(value:nil)
        var tagChangeSubject: BehaviorRelay<Array<String>> = BehaviorRelay(value:[])
        
        lazy var tipView: NTipView = {
            let v = NTipView(frame: ScreenBounds)
            v.textLabel.text = TR("Import.Tip")
            return v
        }()
        
        lazy var nextBtn = UIButton().doNormal(title: TR("Button.Next")).then {
            $0.titleLabel?.autoFont = true
            $0.autoCornerRadius = 28
            $0.isEnabled = false
        }
        
        var index: Int = -1
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
            
            weak var welf = self
            tagList.block = { view, height in
                guard let view = view else {
                    return
                }
                welf?.tagHeightChangeSubject.accept( (view, height))
            }
            
            tagList.tagChangeBlock = { items in
                if let items = items as? [String] {
                    welf?.tagChangeSubject.accept(items)
                } 
            }
            
            tagList.tagEditBlock = { (view, tagView) in
                guard let this = welf , let tagView = tagView else { return  }  
                welf?.editView = EditView(frame: ScreenBounds)
                
                welf?.addSubview((welf?.editView)!)
                welf?.tagList.tagInputField.resignFirstResponder()
                welf?.editView?.inputTF.text = tagView.text
                this.index = tagView.index
                welf?.editView?.inputTF.becomeFirstResponder()
                
                welf?.editView?.completed = { str in
                    guard let str = str else {
                        welf?.tagList.tagInputField.becomeFirstResponder()
                        return
                    }
                    welf?.tagList.tagArray.replaceObject(at: this.index, with: str)
                    welf?.tagList._reloadPreData(false)
                    welf?.tagList.tagInputField.becomeFirstResponder()
                }
            }
        }
        
        lazy var nextBtnControl: UIControl = {
            let v = UIControl(frame: .zero)
            return v
        }()
        
        private func configuration() {
            backgroundColor = .white
            
            
            inputTFContainer.backgroundColor = COLOR.inputbg
            inputTFContainer.borderColor = COLOR.inputborder
            inputTFContainer.borderWidth = 1
            inputTFContainer.autoCornerRadius = 8
            
            inputTF.textColor = UIColor.black
            inputTF.font = XWallet.Font(ofSize: 16, weight: .bold)
            inputTF.autoFont = true
            inputTF.returnKeyType = .done
            inputTF.tintColor = COLOR.inputborder
            inputTF.delegate  = self
            inputTF.attributedPlaceholder = NSAttributedString(string: TR("NickName.Input.Placeholder"), attributes: [.font : XWallet.Font(ofSize: 16),
                                                                                                                      .foregroundColor: COLOR.tip])
            
            inputTFContainer.interactor.snp.makeConstraints { (make) in
                make.centerY.height.equalToSuperview()
                make.left.equalTo(8.auto())
                make.right.equalTo(-8.auto())
            }
            
            
            tagList.autoCornerRadius = 16
            tagList.clipsToBounds = true
            tagList.backgroundColor = COLOR.title.withAlphaComponent(0.03)
            
            tagList.tagInputField.keyboardType = .asciiCapable
            tagList.tagInputField.autocapitalizationType = .none
            
            navBar.backButton.isHidden = false
            navBar.isHidden = false 
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            var pwd = textField.text!.trimmingCharacters(in: .whitespaces)
            pwd = pwd.trimCenterSpace().lowercased()
            tagList.tagArray.replaceObject(at: self.index, with: pwd)
            tagList._reloadPreData(false)
            tagList.tagInputField.becomeFirstResponder()
            inputTFContainer.removeFromSuperview()
            tagList.alpha = 1
            return false
        }
        
        private func layoutUI() {
            addView(contentView)
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            addSubview(navBar)
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            contentView.addSubview(realview)
            realview.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0)
            
            realview.snp.makeConstraints { (make) in
                make.edges.equalTo(contentView)
                make.size.equalTo(contentSize)
            }
            
            realview.addView(titleLabel, subtitleLabel, tagList, tipView, nextBtn)
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
                make.left.right.equalTo(self).inset(24.auto())
            }
            
            tagList.snp.makeConstraints { (make) in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalTo(self).inset(24.auto())
                make.height.equalTo(ImportWalletViewController.View.MIN_HEIHGT) //240
            }
            
            tipView.snp.makeConstraints { (make) in
                make.top.equalTo(tagList.snp.bottom).offset(12.auto())
                make.left.right.equalTo(self).inset(24.auto())
            }
            
            nextBtn.snp.makeConstraints { (make) in
                make.top.equalTo(tagList.snp.bottom).offset(84.auto())
                make.height.equalTo(56.auto())
                make.left.right.equalTo(self).inset(24.auto())
            }
            
            nextBtn.addView(nextBtnControl)
            
            nextBtnControl.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            } 
        }
    }
}

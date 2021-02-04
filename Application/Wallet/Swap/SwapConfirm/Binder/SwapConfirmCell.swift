//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SwapConfirmViewController {
    class TokenPanelCell: FxTableViewCell {
        
        private var viewModel: SwapViewController.AmountsModel?
        lazy var view = TokenPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? SwapViewController.AmountsModel else { return }
            self.viewModel = vm
            let from = vm.from
            let to = vm.to
            view.fromToken.tokenIV.setImage(urlString: from.token.imgUrl, placeHolderImage: from.token.imgPlaceholder)
            view.fromToken.tokenLabel.text = from.token.symbol
            
            view.toToken.tokenIV.setImage(urlString: to.token.imgUrl, placeHolderImage: to.token.imgPlaceholder)
            view.toToken.tokenLabel.text = to.token.symbol

            view.fromToken.amountLabel.text = from.inputformatValue.thousandth()
            view.toToken.amountLabel.text = to.inputformatValue.thousandth()
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (8 + 165).auto()
        }
    }
}

extension SwapConfirmViewController {
    
    class TipViewCell: FxTableViewCell {
        
        static var message = TR("Swap.Confirm.Input")
        static var outputMessage = TR("Swap.Confirm.Output")
        
        private var viewModel: Any?
        lazy var view = SwapTipView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? SwapViewController.AmountsModel else { return }
            self.viewModel = vm
            
            if vm.amountsType == .out {
                view.titleLabel.text = TR(TipViewCell.outputMessage, vm.minValue +  " " + vm.amountsInput.token.symbol)
            } else {
                view.titleLabel.text = TR(TipViewCell.message, vm.maxValue + " " + vm.amountsInput.token.symbol ) 
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            let width =  ScreenWidth - (24 * 2).auto()
            guard let vm = model as? SwapViewController.AmountsModel else { return 0}
            
            var  temp = ""
            if vm.amountsType == .out {
                temp = TR(TipViewCell.outputMessage, vm.maxOrMin)
            } else {
                temp = TR(TipViewCell.message, vm.maxOrMin)
            }
            
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = temp
                $0.autoFont = true }.font
            let height = temp.height(ofWidth: width, attributes:  [.font: font1])
            return (16 + 32).auto() + height
        }
    }
}
                


extension SwapViewController {
    
    class FeeCell: FxTableViewCell {
            
            private var viewModel: Any?
            lazy var view = FeePannel(frame: ScreenBounds)
            override func getView() -> UIView { view }
            
            override func bind(_ viewModel: Any?) {
                guard let vm = viewModel as? AmountsModel else { return }
                self.viewModel = vm
                
                weak var welf = self
                
                view.maxSold.titleLabel.text = TR("Maxmum sold")
                view.priceImpact.titleLabel.text = TR("Uniswap.Fee.Text1")
                view.providerFee.titleLabel.text = TR("Uniswap.Fee.Text2")
                
                switch vm.amountsType  {
                case .in:
                    welf?.view.maxSold.titleLabel.text = TR("Maxmum sold")
                    welf?.view.soldValue.text = "\(vm.maxValue.thousandth()) \(vm.from.token.symbol)"
                    break
                case .out:
                    welf?.view.maxSold.titleLabel.text = TR("Uniswap.Fee.Text3")
                    welf?.view.soldValue.text = "\(vm.minValue.thousandth()) \(vm.to.token.symbol)"
                    break
                case .null:
                    break
                }
                
                view.priceImpact.subTitleLabel.text = vm.priceImpact.thousandth(ThisAPP.CurrencyDecimal) + "%"
                if vm.priceImpact.isLessThan(decimal: "0.01") {
                    view.priceImpact.subTitleLabel.textColor = RGB(36, 163, 78)
                    view.priceImpact.subTitleLabel.text = "<0.01%"
                } else if vm.priceImpact.isLessThan(decimal: "3") {
                    view.priceImpact.subTitleLabel.textColor = UIColor.black
                } else {
                    view.priceImpact.subTitleLabel.textColor = RGB(251, 79, 94)
                }
                
                let mobilityValue = vm.from.inputValue.mul(String(0.003)).div(String((1.0 - 0.003)),4)
                view.providerValue.text = "\(mobilityValue) \(vm.from.token.symbol)"
                
                view.soldHelpBtn.rx.tap.subscribe(onNext: { (_) in
                    welf?.router(event: "Sold.Help")
                }).disposed(by: reuseBag)
                
                view.priceHelpBtn.rx.tap.subscribe(onNext: { (_) in
                    welf?.router(event: "Price.Help")
                }).disposed(by: reuseBag)
                
                view.providerHelpBtn.rx.tap.subscribe(onNext: { (_) in
                   welf?.router(event: "Provider.Help")
                }).disposed(by: reuseBag)
 
    //            maxSold.accept("0.038 ETH")
    //            priceImpact.accept(NSAttributedString(string: "<0.3%" ,
    //                                                  attributes: [.font : XWallet.Font(ofSize: 14),
    //                                                               .foregroundColor: HDA(0x71A800)]))
    //            fee.accept("0.00000398 ETH")
    //            price.accept("0.26891 ETH per USDC")
    //            tempexchangeRate.accept(true)
            }
            
            override class func height(model: Any?) -> CGFloat {
                return 132.auto()
            }
        }
}

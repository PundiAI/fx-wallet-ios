//
//  CashBuyCell.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import RxSwift
import RxCocoa

extension NumberFormatter {
    static let shared = NumberFormatter()
}
extension StringProtocol {
    var doubleValue: Double? {
        return NumberFormatter.shared.number(from: String(self))?.doubleValue
    }
}

class CashBuyTxInputCell: FxTableViewCell, UITextFieldDelegate {
    private var viewModel: CashBuyViewModel?
    lazy var view = CashBuyTxInputContentCell(frame: ScreenBounds)
    override func getView() -> UIView { view }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        view.inputTF.delegate = self
        view.inputTF.placeholder = "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bind(_ viewModel: Any?) {
        guard let vm = viewModel as? CashBuyViewModel else { return }
        self.viewModel = vm
        view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
        view.tokenLabel.text = vm.coin.token
        view.addressTitleLabel.text = TR("CryptoBank.Cash.Input.Address.T")
        let placeholder = TR("CryptoBank.Cash.Input.Address.Placeholder")
        view.addressLabel.text = placeholder
        
        vm.addressOb.map { (account) -> (String, UIFont) in
            if let _account = account {
                return (_account.address, XWallet.Font(ofSize: 14))
            }
            return (placeholder, XWallet.Font(ofSize: 16, weight:.medium))
        }.subscribe(onNext: {[weak self] (text, font) in
            self?.view.addressLabel.text = text
            self?.view.addressLabel.font = font
        }).disposed(by: reuseBag)
    
        view.addressButton.rx.tap.flatMap {[weak self] (_) -> Observable<Keypair> in
            guard let this = self else { return .empty() }
            return this.selecteAccount(vm.coin).filterNil()
        }.subscribe(onNext: { [weak self] (account) in
            self?.viewModel?.addressOb.accept(account)
        }).disposed(by: reuseBag)
        
        view.inputTF.rx.text.changed.map { (text) -> String? in
            if let _text = text {
                return NumberFormatter.shared.number(from: _text)?.stringValue
            }
            return text
        }.bind(to: vm.inputTxOb)
            .disposed(by: reuseBag)
    }
    
    override class func height(model: Any?) -> CGFloat { (8 + 205 + 32).auto() }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.inputVIew.textFieldProxy.endEditing?(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.inputVIew.textFieldProxy.beginEditing?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let decimalSeparator = NumberFormatter.shared.decimalSeparator ?? "."
        let groupSeparator = NumberFormatter.shared.groupingSeparator ?? ","
        
        let inverseSet = CharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        if range.length == 1 && string == "" {
            return true
        }
        
        if filtered == string {
            if var newTextString = textField.text {
                newTextString = newTextString.appending(string)
                newTextString = NumberFormatter.shared.number(from: newTextString)?.stringValue ?? newTextString
                let numberDecimal = NSDecimalNumber(string: newTextString)
                if newTextString == numberDecimal.description {
                    return true
                }else {
                    let dotsCount = newTextString.components(separatedBy:decimalSeparator).count
                    return (range.length == 0 && string == "0") && dotsCount == 2
                }
            }
            return true
        } else {
            if string == decimalSeparator || string == groupSeparator {
                let countDots = textField.text!.components(separatedBy:decimalSeparator).count - 1
                let countCommas = textField.text!.components(separatedBy:groupSeparator).count - 1
                if countDots == 0 && countCommas == 0 {
                    return true
                } else {
                    return false
                }
            } else  {
                return false
            }
        }
    }
    
    private func selecteAccount(_ filter: Coin?) ->Observable<Keypair?> {
        return Observable.create { (observer) -> Disposable in
            let wallet = XWallet.currentWallet!.wk
            Router.showSelectAccount(wallet: wallet, current: nil, filterCoin: filter) { (vc, coin, account) in
                Router.dismiss(vc) {
                    observer.onNext(account)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}


class CashBuyConfirmTxCell: FxTableViewCell {
    private var viewModel: CashBuyViewModel?
    lazy var view = CashBuyConfirmTxContentCell(frame: ScreenBounds)
    override func getView() -> UIView { view }
    
    override func bind(_ viewModel: Any?) {
        guard let vm = viewModel as? CashBuyViewModel else { return }
        self.viewModel = vm
          
        view.submitButton.isEnabled = false
        Observable.combineLatest(vm.addressOb, vm.agreeOb, vm.inputTxOb)
            .flatMap { (userAddress, isAgree, swapAmount) -> Observable<Bool> in
            if let _ = userAddress, let amountString = swapAmount {
                let numberDecimal = NSDecimalNumber(string: amountString)
                if isAgree && numberDecimal.doubleValue > 0 {
                    return .just(true)
                }
            }
            return .just(false)
        }
        .bind(to: view.submitButton.rx.isEnabled)
        .disposed(by: reuseBag)
        
        let checkBoxView = view.checkBox
        vm.agreeOb.bind(to: view.checkBoxState).disposed(by: reuseBag)
        vm.agreeOb.bind(to: checkBoxView.rx.isSelected).disposed(by: reuseBag)
        vm.agreeOb.accept(true)
        view.checkBox.action {
            vm.agreeOb.accept(!checkBoxView.isSelected)
        }
        view.tipButton.isEnabled = false
        view.tipButton.action {
            Router.showWebViewController(url: ThisAPP.WebURL.termServiceURL)
        } 
    }
    
    override public class func height(model:Any? = nil) -> CGFloat { 
        let tipHeight = TR("AgreeToTerms").height(ofWidth: ScreenWidth - 24.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
        return (56 + 20).auto() + tipHeight
    }
}

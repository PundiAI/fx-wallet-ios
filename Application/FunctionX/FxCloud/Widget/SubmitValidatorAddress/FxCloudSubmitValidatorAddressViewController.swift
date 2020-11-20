import FunctionX
import RxCocoa
import SwiftyJSON
import TrustWalletCore
import WKKit
extension FxCloudSubmitValidatorAddressViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let hrp = context["hrp"] as? String,
            let chainName = context["chainName"] as? String else { return nil }
        let vc = FxCloudSubmitValidatorAddressViewController(wallet: wallet, hrp: hrp, chainName: chainName)
        if let parameter = context["parameter"] as? [String: Any] { vc.parameter = JSON(parameter) }
        vc.confirmHandler = context["handler"] as? (Keypair) -> Void
        return vc
    }
}

class FxCloudSubmitValidatorAddressViewController: FxCloudWidgetActionViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, hrp: String, chainName: String) {
        self.wallet = wallet
        super.init(hrp: hrp, chainName: chainName)
    }

    let wallet: Wallet
    var confirmHandler: ((Keypair) -> Void)?
    var selectCell: UITableViewCell?
    let selectKeypair = BehaviorRelay<Keypair?>(value: nil)
    override var titleText: String { TR("CloudWidget.SubDelegatorAddr.Title") }
    override func bindList() {
        super.bindList()
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = "Address List" }
        selectCell = listBinder.push(SelectValidatorAddressCell.self)
        listBinder.didSeletedBlock = { [weak self] _, _, cell in
            guard let this = self, cell is SelectValidatorAddressCell else { return }
            Router.showAnyHrpSelectAddressAlert(wallet: this.wallet.wk, hrp: this.hrp) { vc, keypair in
                Router.dismiss(vc, animated: false, completion: nil)
                this.selectKeypair.accept(keypair)
                this.listBinder.pop(cell, refresh: false)
                this.listBinder.push(ValidatorAddressCell.self, vm: ["walletAddress": keypair.address, "validatorAddress": this.validatorAddress])
                this.listBinder.refresh()
            }
        }
    }

    override func router(event: String, context: [String: Any]) {
        guard event == "delete", let cell = context[eventSender] as? UITableViewCell else { return }
        selectKeypair.accept(nil)
        listBinder.pop(cell, refresh: false)
        listBinder.push(selectCell)
        listBinder.refresh()
    }

    override func bindAction() {
        wk.view.confirmButton.title = TR("Submit_U")
        selectKeypair.map { $0 == nil }
            .bind(to: wk.view.confirmButton.rx.isHidden)
            .disposed(by: defaultBag)
        wk.view.confirmButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let this = self, let keypair = self?.selectKeypair.value else { return }

            self?.confirmHandler?(keypair)
            let resultVC = FxCloudSubmitValidatorAddressCompletedViewController(hrp: "", chainName: "")
            resultVC.walletAddress = keypair.address
            resultVC.validatorAddress = this.validatorAddress
            this.navigationController?.pushViewController(resultVC, animated: true)
        }).disposed(by: defaultBag)
    }

    private var validatorAddress: String {
        guard let keypair = selectKeypair.value else { return "" }
        let validatorHrp = hrp + "valoper"
        return FunctionXAddress(hrpString: validatorHrp, publicKey: keypair.publicKey().data)?.description ?? ""
    }
}

class FxCloudSubmitValidatorAddressCompletedViewController: FxCloudWidgetActionCompletedViewController {
    fileprivate var walletAddress = ""
    fileprivate var validatorAddress = ""
    override func bindList() {
        super.bindList()
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = TR("CloudWidget.SubDelegatorAddr.ValidatorSettings") }
        listBinder.push(ValidatorAddressCell.self, vm: ["walletAddress": walletAddress, "validatorAddress": validatorAddress])
    }
}

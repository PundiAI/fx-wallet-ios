import FunctionX
import RxCocoa
import SwiftyJSON
import TrustWalletCore
import WKKit
extension FxCloudSubmitValidatorKeypairViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let hrp = context["hrp"] as? String,
            let chainName = context["chainName"] as? String else { return nil }
        let vc = FxCloudSubmitValidatorKeypairViewController(wallet: wallet, hrp: hrp, chainName: chainName)
        if let parameter = context["parameter"] as? [String: Any] { vc.parameter = JSON(parameter) }
        vc.confirmHandler = context["handler"] as? (Keypair) -> Void
        return vc
    }
}

class FxCloudSubmitValidatorKeypairViewController: FxCloudWidgetActionViewController {
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
    override var titleText: String { TR("CloudWidget.SubValidatorKeypair.Title") }
    override func bindList() {
        super.bindList()
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = TR("CloudWidget.SubValidatorKeypair.ValidatorKeys") }
        selectCell = listBinder.push(SelectKeypairCell.self)
        listBinder.didSeletedBlock = { [weak self] _, _, cell in
            guard let this = self, cell is SelectKeypairCell else { return }
            Router.showAuthorizeDappAlert(dapp: .fxCloudWidget, types: [5]) { authVC, allow in
                Router.dismiss(authVC, animated: false) {
                    guard allow else { return }
                    Router.showFxValidatorSelectKeypairAlert(wallet: this.wallet.wk, hrp: "\(this.hrp)valconspub") { vc, keypair in
                        vc?.dismiss(animated: true, completion: nil)
                        this.selectKeypair.accept(keypair)
                        this.listBinder.pop(cell, refresh: false)
                        this.listBinder.push(KeypairCell.self) { $0.view.publicKeyLabel.text = self?.validatorPublicKey }
                        this.listBinder.refresh()
                    }
                }
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
            let resultVC = FxCloudSubmitValidatorKeypairCompletedViewController(this.validatorPublicKey)
            this.navigationController?.pushViewController(resultVC, animated: true)
        }).disposed(by: defaultBag)
    }

    private var validatorPublicKey: String {
        guard let keypair = selectKeypair.value else { return "" }
        let validatorPKHrp = hrp + "valconspub"
        let validatorKeypair = FunctionXValidatorKeypair(keypair.privateKey)
        return validatorKeypair.encodedPublicKey(hrp: validatorPKHrp) ?? ""
    }
}

class FxCloudSubmitValidatorKeypairCompletedViewController: FxCloudWidgetActionCompletedViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ publicKey: String) {
        self.publicKey = publicKey
        super.init(hrp: "", chainName: "")
    }

    let publicKey: String
    override func bindList() {
        super.bindList()
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = TR("CloudWidget.SubValidatorKeypair.ValidatorKeys") }
        listBinder.push(KeypairCell.self, vm: publicKey)
    }
}

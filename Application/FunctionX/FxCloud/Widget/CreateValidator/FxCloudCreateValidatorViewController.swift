import FunctionX
import SwiftyJSON
import TrustWalletCore
import WKKit
private typealias DescCell = WKTableViewCell.DescCell
private typealias DescCellViewModel = WKTableViewCell.DescCellViewModel
extension FxCloudCreateValidatorViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let hrp = context["hrp"] as? String,
            let chainName = context["chainName"] as? String,
            let txParams = context["txParams"] as? [String: Any] else { return nil }
        let vc = FxCloudCreateValidatorViewController(hrp: hrp, chainName: chainName, txParams: txParams)
        if let parameter = context["txParams"] as? [String: Any] { vc.parameter = JSON(parameter) }
        vc.confirmHandler = context["handler"] as? () -> Void
        return vc
    }
}

class FxCloudCreateValidatorViewController: FxCloudWidgetActionViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(hrp: String, chainName: String, txParams: [String: Any]) {
        self.txParams = JSON(txParams)
        super.init(hrp: hrp, chainName: chainName)
    }

    let txParams: JSON
    var confirmHandler: (() -> Void)?
    override var titleText: String { TR("CloudWidget.CreateValidator.Title") }
    override func bindList() {
        super.bindList()
        wk.view.listView.isScrollEnabled = true
        listBinder.push(HeaderCell.self)
        listBinder.push(DescCell.self, vm: DescCellViewModel(title: TR("CreateValidator.ValidatorName"), content: text(forKey: "name")))
        listBinder.push(DescCell.self, vm: DescCellViewModel(title: TR("CreateValidator.ValidatorId"), content: text(forKey: "identity")))
        listBinder.push(DescCell.self, vm: DescCellViewModel(title: TR("CreateValidator.ValidatorWeb"), content: text(forKey: "website"), contentIsLink: true))
        listBinder.push(DescCell.self, vm: DescCellViewModel(title: TR("Description"), content: text(forKey: "description")))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.CommissionRate"), content: text(forKey: "commissionRate", isRate: true)))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.MaxCommissionRate"), content: text(forKey: "maxCommissionRate", isRate: true)))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.MaxChangeRate"), content: text(forKey: "maxChangeRate", isRate: true)))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.MinSelfDelegation"), content: text(forKey: "minSelfDelegation", isAmount: true)))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.ValidatorAddress"), content: text(forKey: "validatorAddress")))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.ValidatorPublicKey"), content: text(forKey: "validatorPublicKey")))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.DelegatorAddress"), content: text(forKey: "delegatorAddress")))
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("CreateValidator.DelegatorAmount"), content: text(forKey: "delegatorAmount", isAmount: true)))
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(164, 0, .clear))
    }

    private func text(forKey key: String, isRate: Bool = false, isAmount: Bool = false) -> String {
        let text = txParams[key].stringValue
        if isRate {
            return String(format: "%.2f", text.mul("100").f) + " %"
        }
        if isAmount {
            return "\(text.fxc.thousandth()) \(txParams["denom"].stringValue.uppercased())"
        }
        return text
    }

    override func bindAction() {
        wk.view.confirmButton.title = TR("CloudWidget.CreateValidator.Confirm")
        wk.view.confirmButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.confirmHandler?()
        }).disposed(by: defaultBag)
    }

    override func configuration() {
        super.configuration()
        addShadow()
    }
}

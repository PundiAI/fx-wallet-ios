import FunctionX
import WKKit
extension FxCloudSubmitValidatorPublicKeyCompletedViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let keypair = context["keypair"] as? FunctionXValidatorKeypair else { return nil }
        return FxCloudSubmitValidatorPublicKeyCompletedViewController(keypair)
    }
}

class FxCloudSubmitValidatorPublicKeyCompletedViewController: FxCloudWidgetActionCompletedViewController {
    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ keypair: FunctionXValidatorKeypair) {
        self.keypair = keypair
        super.init(hrp: "", chainName: "")
    }

    let keypair: FunctionXValidatorKeypair
    override func bindList() {
        super.bindList()
        listBinder.push(InfoTitleCell.self) { $0.titleLabel.text = TR("CloudWidget.SubValidatorPK.ValidatorPublickey") }
        listBinder.push(PublicKeyCell.self, vm: keypair.encodedPublicKey() ?? "")
    }
}

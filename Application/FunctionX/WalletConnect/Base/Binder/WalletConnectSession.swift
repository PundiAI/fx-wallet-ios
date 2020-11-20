import FunctionX
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
extension WalletConnectSession {
    private static var references: [String: WalletConnectSession] = [:]
    static func retain(session: WalletConnectSession, forId id: String? = nil) {
        let id = id ?? session.id
        references[id] = session
    }

    static func release(session: WalletConnectSession, forId id: String? = nil) {
        let id = id ?? session.id
        references[id] = nil
    }

    static func session<T: WalletConnectSession>(forId id: String) -> T? {
        if let session = references[id] as? T {
            return session
        }
        return nil
    }

    func retain() { Self.retain(session: self) }
    func release() { Self.release(session: self) }
}

class WalletConnectSession {
    var id: String
    let url: String
    init(id: String? = nil, url: String) {
        self.url = url
        if let id = id {
            self.id = id
        } else if let session = WCSession.from(string: url) {
            self.id = session.bridge.absoluteString + session.topic
        } else {
            self.id = url
        }
        XWallet.Event.subscribe(.AppDidBecomeActive, { [weak self] _, _ in
            self?.reconnectIfNeed()
        }, disposedBy: bag)
    }

    private var bag = DisposeBag()
    private(set) var peerMeta: WCPeerMeta?
    private(set) var interactor: WCInteractor?
    private(set) var currentRequestId: Int64 = 0
    var autoReconnect = true
    private var disconnectdByUser = false
    public var networkReachable: (() -> Bool) = { true }
    lazy var error = BehaviorRelay<Error?>(value: nil)
    lazy var isConneting = BehaviorRelay<Bool>(value: false)
    lazy var isConnected = BehaviorRelay<Bool>(value: false)
    lazy var didApproveSession = PublishSubject<Bool>()
    weak var viewController: UIViewController?
    func disconnect() {
        disconnectdByUser = true
        interactor?.onDisconnect = nil
        interactor?.killSession().cauterize()
        interactor?.disconnect()
        peerMeta = nil
        interactor = nil
        currentRequestId = 0
    }

    func connect() {
        guard isDisconnected, let session = WCSession.from(string: url) else { return }
        let clientMeta = WCPeerMeta(name: "", url: "")
        let interactor = WCInteractor(session: session, meta: clientMeta, clientId: clientId)
        bind(interactor: interactor)
        interactor.connect().cauterize()
    }

    var chainId: Int { 1 }
    func accounts(for _: WCSessionRequestParam) -> [String] { return [] }
    func bind(interactor: WCInteractor) {
        self.interactor = interactor
        disconnectdByUser = false
        weak var welf = self
        interactor.disableSSLCertValidation()
        interactor.onError = { welf?.error.accept($0) }
        interactor.onDisconnect = {
            welf?.error.accept($0)
            if welf?.autoReconnect == true {
                welf?.reconnectIfNeed()
            }
        }
        interactor.didUpdateState = { state in
            welf?.isConneting.accept(state == .connecting)
            welf?.isConnected.accept(state == .connected)
        }
        interactor.onSessionRequest = { id, peerParam in welf?.approveSession(id, peerParam) }
        interactor.onSessionBeKilled = { welf?.onSessionBeKilled() }
        interactor.onCustomRequest = { _, req in
            let request = JSON(req)
            if let method = request["method"].string {
                welf?.currentRequestId = request["id"].int64Value
                let parameter: JSON
                if request["params"].arrayValue.count == 1, let paramsString = request["params"].arrayValue.firstObject()?.string {
                    parameter = JSON(parseJSON: paramsString)
                } else {
                    parameter = request["params"]
                }
                welf?.handleMethod(request, method, parameter)
            }
        }
    }

    var sessionIsAuthed: Bool { false }
    func approveSession(_ id: Int64, _ peerParam: WCSessionRequestParam) {
        approveSession(true, id, peerParam)
    }

    func approveSession(_ approved: Bool, _: Int64, _ peerParam: WCSessionRequestParam) {
        if !approved {
            didApproveSession.onNext(false)
        } else {
            peerMeta = peerParam.peerMeta
            interactor?.approveSession(accounts: accounts(for: peerParam), chainId: chainId).cauterize()
            didApproveSession.onNext(true)
        }
    }

    func onSessionBeKilled() {
        disconnect()
        release()
    }

    func handleMethod(_: JSON, _: String, _: JSON) {}
    private func reconnectIfNeed() {
        if !isDisconnected || disconnectdByUser || !networkReachable() { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.interactor?.connect().cauterize()
        }
    }

    var clientId: String {
        if let cacheId = UserDefaults.standard.string(forKey: "fx.wc.clientId") {
            return cacheId
        } else {
            let id = UUID().uuidString
            UserDefaults.standard.set(id, forKey: "fx.wc.clientId")
            return id
        }
    }

    var isDisconnected: Bool { interactor == nil || interactor?.state == .disconnected }
    func response(code: Int = 200, msg: String = "", data: Any) {
        let result: [String: Any] = ["code": code, "msg": msg, "data": data]
        let resultJson = JSON(result).rawString() ?? ""
        interactor?.approveRequest(id: currentRequestId, result: resultJson).cauterize()
    }

    func error(_ e: WKError.Code, msg: String = "", data: Any) {
        response(code: e.rawValue, msg: msg, data: data)
    }
}

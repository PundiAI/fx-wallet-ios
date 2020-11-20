//
//  ChatViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit

extension WKWrapper where Base == ChatViewController {
    var view: ChatViewController.View { return base.view as! ChatViewController.View }
}

extension ChatViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let receiver = context["receiver"] as? SmsUser,
            let wallet = context["wallet"] as? FxWallet else { return nil }

        return ChatViewController(receiver: receiver, wallet: wallet)
    }
}

class ChatViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(receiver: SmsUser, wallet: FxWallet) {
        viewModel = ViewModel(receiver: receiver, wallet: wallet)
        super.init(nibName: nil, bundle: nil)
    }

    let viewModel: ViewModel
    var wallet: FxWallet { viewModel.wallet }
    var receiver: SmsUser { viewModel.service.receiver }

    fileprivate lazy var listBinder = WKTableViewBinder<CellViewModel>(view: wk.view.listView)
    fileprivate lazy var snapshotBinder = SnapshotBinder()

    fileprivate var sendTextAction: Action<String, JSON>!

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()

        bindNavBar()
        bindListView()
        bindSentText()
        bindKeyboard()
        bindTextInputPanel()

        fetchData()
    }

    private func fetchData() {
        listBinder.refresh()
    }

    private func bindNavBar() {
        navigationBar.isHidden = true

        weak var welf = self
        wk.view.nameLabel.text = receiver.name
        wk.view.navBar.backButton.rx.tap.subscribe(onNext: { _ in
            welf?.navigationController?.popViewController(animated: true)
        }).disposed(by: defaultBag)

        wk.view.navBar.rightButton.rx.tap.subscribe(onNext: { _ in
            Router.showChatMessageEncryptedTipAlert()
        }).disposed(by: defaultBag)

        viewModel.lastUpdateDate
            .bind(to: wk.view.updateDateLabel.rx.text)
            .disposed(by: defaultBag)

        //        let item = UIBarButtonItem(customView: wk.view.navLeftView)
        //        navigationBar.navigationItem.leftBarButtonItems?.append(item)
        //        navigationBar.action(.right, imageName: "Chat.Lock") { () in
        //            Router.showChatMessageEncryptedTipAlert()
        //        }?.config(config: { $0?.tintColor = HDA(0x14ff66) })
    }

    private func bindListView() {
        weak var welf = self
        let listView = wk.view.listView
        listView.viewModels = { section in
            guard let this = welf else { return section }

            for vm in this.viewModel.items {
                section.push(Cell.cls(for: vm), m: vm)
            }
            return section
        }

        //        viewModel.refreshItems.errors.subscribe(onNext: { [] (error) in
        //            if error.isNoData { return }
        //            welf?.hud?.text(m: error.asWKError().msg)
        //        }).disposed(by: defaultBag)

        viewModel.firstLoadFinished
            .filter { $0 }
            .delay(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in listView.scrollToBottom(true) })
            .disposed(by: defaultBag)

        viewModel.needReload
            .delay(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in

                listView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    listView.scrollToBottom(true)
                }
            })
            .disposed(by: defaultBag)

        listBinder.bindListError = {}
        listBinder.bindListFooter = {}
        listBinder.refreshWithHUD = false
        listBinder.bind(viewModel)
    }

    private func bindSentText() {
        weak var welf = self
        let textInputTV = wk.view.textInputTV
        let hasInput = textInputTV.interactor.rx.text.map { $0?.count != 0 }

        sendTextAction = Action(workFactory: { (text) -> Observable<JSON> in
            guard let this = welf else { return Observable.empty() }
            return this.viewModel.service.send(sms: text)
        })
        _ = sendTextAction.elements.subscribe(onNext: { _ in }) // hold the sending signal

        Observable.combineLatest(hasInput, sendTextAction.executing)
            .map { $0.0 && !$0.1 }
            .bind(to: wk.view.textInputPanel.sendTextButton.rx.isEnabled)
            .disposed(by: defaultBag)

        wk.view.textInputPanel.sendTextButton.rx.tap.subscribe(onNext: { _ in
            guard textInputTV.text.isNotEmpty else { return }

            welf?.sendTextAction.execute(textInputTV.text)
            textInputTV.text = ""
        }).disposed(by: defaultBag)
    }

    private func bindTextInputPanel() {
        weak var welf = self
        let textInputPanel = wk.view.textInputPanel
        textInputPanel.sendGiftButton.rx.tap.subscribe(onNext: { _ in
            guard let this = welf else { return }
            Router.presentSendCryptoGift(receiver: this.receiver, wallet: this.wallet)
        }).disposed(by: defaultBag)

        // textInputTV.height
        let padding = 8
        wk.view.textInputTV.interactor.rx.text.subscribe(onNext: { value in

            let text = value ?? ""
            var height: CGFloat = 40
            let inputWidth = textInputPanel.inputWidth
            if text.count > 12 {
                height = text.height(ofWidth: inputWidth, attributes: [.font: XWallet.Font(ofSize: 16)]) + 12
                height = max(40, height)
                height = min(100, height)
            }
            height += CGFloat(padding * 2)
            if textInputPanel.height != height {
                textInputPanel.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            }
        }).disposed(by: defaultBag)

        let listView = wk.view.listView
        listView.rx.didEndDragging.subscribe(onNext: { _ in
            guard textInputPanel.textInputTV.interactor.isFirstResponder,
                listView.panGestureRecognizer.translation(in: listView.superview).y > 0
            else {
                return
            }

            welf?.view.endEditing(true)
        }).disposed(by: defaultBag)
    }

    override func router(event: String, context: [String: Any]) {
        guard let cell = context[eventSender] as? Cell,
            let sms = cell.getViewModel() else { return }

        if event == Cell.longTapEvent {
            showSnapshot(cell: cell, sms: sms.rawValue)
        } else if event == Cell.resendTapEvent {
            _ = viewModel.service.resend(sms: sms).subscribe()
        }
    }

    private func showSnapshot(cell: Cell, sms: SmsMessage) {
        weak var welf = self
        let text = cell.snapshotText()
        let onClickCopy = {
            UIPasteboard.general.string = text
            welf?.view.hud?.text(m: TR("Copied"))
        }

        let onClickInfo = {
            guard let this = welf else { return }
            Router.presentChatMessageInfo(receiver: this.receiver, wallet: this.wallet, sms: sms)
        }

        snapshotBinder.show(snapshot: cell, inView: view, onClickCopy: onClickCopy, onClickInfo: onClickInfo)
    }

    var offsetBeforeInput: CGPoint?
    private func bindKeyboard() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self, this.navigationController?.topViewController == this else { return }

                this.wk.view.textInputTV.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y

                this.wk.view.contentView.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view).offset(-margin)
                }

                if this.offsetBeforeInput == nil {
                    let listView = this.wk.view.listView
                    this.offsetBeforeInput = listView.contentOffset
                    listView.setContentOffset(CGPoint(x: 0, y: listView.contentOffset.y + margin), animated: listView.isDecelerating)
                }

                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self, this.navigationController?.topViewController == this else { return }

                this.offsetBeforeInput = nil
                this.wk.view.textInputTV.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                this.wk.view.contentView.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view)
                }
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
    }
}

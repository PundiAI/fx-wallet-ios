//
//  TokenInfoViewController.swift
//  XWallet
//
//  Created by Pundix54 on 2020/7/16.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import Hero
import UIKit
import WKKit

class ExampleBaseViewController: UIViewController {
    let dismissButton = UIButton(type: .system)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = HDA(0x080A32)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))

        dismissButton.setTitle("Back", for: .normal)
        dismissButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        dismissButton.hero.id = "back button"
        view.addSubview(dismissButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dismissButton.sizeToFit()
        dismissButton.center = CGPoint(x: 30, y: 64)
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onTap() {
        back() // default action is back on tap
    }
}

class TokenInfoViewController: ExampleBaseViewController {
    let tabBarView = UIImageView()
    let topContentView = UIView()
    let botContentView = UIView()
    let tokenView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        topContentView.backgroundColor = UIColor.white
        topContentView.hero.id = "token_list_background_0"
        topContentView.cornerRadius = 40
        view.addSubview(topContentView)

        topContentView.addSubview(tokenView)
        tokenView.backgroundColor = HDA(0xF4F4F4)

        botContentView.cornerRadius = 40
        botContentView.backgroundColor = UIColor.white
        botContentView.hero.modifiers = [.translate(y: 500),
                                         .useGlobalCoordinateSpace,
                                         .whenAppearing(.fade),
                                         .whenDismissing(.fade),
                                         .spring(stiffness: 250, damping: 25)]
        view.addSubview(botContentView)
        view.addSubview(tabBarView)

        tabBarView.backgroundColor = UIColor.clear
        tabBarView.image = (Router.rootController as? FxTabBarController)?.tabBar.asImage()
        tabBarView.alpha = 0
        let height = (Router.rootController as? FxTabBarController)?.tabBar.height ?? 83
        tabBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        tabBarView.hero.modifiers = [.whenPresenting(.fade),
                                     .whenDismissing(.opacity(1))]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topContentView.frame = CGRect(x: 0, y: 0, width: view.width, height: 300)
        tokenView.frame = CGRect(x: 0, y: 300 - 115, width: view.width, height: 115)
        botContentView.frame = CGRect(x: 0, y: 450, width: view.width, height: view.bounds.height - 450)
    }
}

//
//  TokenInfoAnimation.swift
//  XWallet
//
//  Created by Pundix54 on 2020/7/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import Hero
import pop
import RxCocoa
import RxSwift
import WKKit

extension TokenInfoViewController.View {
    func setAnimation() {
        topContentView.hero.id = "token_list_background_0"
        botContentView.hero.modifiers = [.translate(y: 500),
                                         .useNormalSnapshot,
                                         .whenPresenting(.forceNonFade),
                                         .whenDismissing(.fade),
                                         .spring(stiffness: 250, damping: 25)]

        tabBarView.hero.modifiers = [.delay(0.001), .whenPresenting(.opacity(1)),
                                     .whenDismissing(.opacity(1))]
    }
}

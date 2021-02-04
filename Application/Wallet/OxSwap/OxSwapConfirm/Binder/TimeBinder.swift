//
//  TimeBinder.swift
//  fxWallet
//
//  Created by May on 2020/12/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension OxSwapConfirmViewController {
    
    class TimeBinder: NSObject {
        
        private var timer: Timer?
        
        init(view: ActionPannel) {
            self.view = view
            super.init()
        }
        
        let view: ActionPannel
        
        func bind() {
            timer?.invalidate()
            start()
        }
        
        func reset() {
            timer?.invalidate()
        }
        
        func start() {
            
            let index = 30
            let currentTime = NSDate().timeIntervalSince1970
            view.timerOut = false
            updateText(index)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self](t) in
                guard let this = self else { t.invalidate(); return }
                let now =  NSDate().timeIntervalSince1970
                var tagIndx  =  index - Int(now - currentTime)
                if tagIndx <= 0 { tagIndx = 0 }
                this.updateText(tagIndx)
                if tagIndx == 0 {
                    this.timerOut()
                }
            })
        }
        
        func updateText(_ idx: Int) {
            view.titleLabel.text = TR("Ox.Order.Timer", idx)
        }
        
        func timerOut() {
            reset()
            view.timerOut = true
        }
    }
}

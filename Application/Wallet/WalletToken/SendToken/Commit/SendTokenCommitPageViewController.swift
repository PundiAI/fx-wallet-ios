//
//  SendTokenInputPageViewController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/4/13.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class SendTokenCommitPageViewController: BaseButtonBarPagerTabStripViewController<SendTokenCommitPageBarCell>, UICollectionViewDelegateFlowLayout {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        
        self.recentList = SendTokenCommitRecentPageListBinder(wallet: wallet, coin: coin)
        self.mineList = SendTokenCommitMinePageListBinder(wallet: wallet, coin: coin)
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.configuration()
        self.layoutUI()
    }
    
//    let dappList: TokenInfoDappListBinder
    let mineList: SendTokenCommitMinePageListBinder
    let recentList: SendTokenCommitRecentPageListBinder
    var listControllers: [SendTokenCommitPageListBinder] { [recentList, mineList] }
    private var lineView: PagerTabStriButtonBarViewDecorator?
    
    var buttonBarHeight: CGFloat { SendTokenCommitPageListBinder.topEdge }
    
    func refresh() {
        
    }
    
    private func didMove(to index: SendTokenCommitPageBarCell?) {
        guard let type = index?.type else { return }
        
        switch type {
        case .recent:
            mineList.refresh()
        case .mine:
            recentList.refresh()
        }
    }
    
    //MARK: BaseButtonBarPagerTabStripViewController
    let itemWidth = ScreenWidth * 0.3333
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let w = (ScreenWidth - itemWidth) * 0.5
        return UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] { return listControllers }
    
    override func configure(cell: SendTokenCommitPageBarCell, for indicatorInfo: IndicatorInfo) {
        cell.bind(indicatorInfo)
    }
    
    private func configuration() {
        
        settings.style.buttonBarHeight = 0
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarLeftContentInset = 0.001
        settings.style.buttonBarRightContentInset = 0.001
        settings.style.buttonBarMinimumLineSpacing = 0.001
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        
        let itemWidth = self.itemWidth
        buttonBarItemSpec = ButtonBarItemSpec.cellClass(width: { _ in itemWidth })
        changeCurrentIndexProgressive = {[weak self](oldCell: SendTokenCommitPageBarCell?, newCell: SendTokenCommitPageBarCell?,
            progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.isSelected = false
            newCell?.isSelected = true
            self?.didMove(to: newCell)
        }
    }
    
    private func layoutUI() {
        self.view.backgroundColor = HDA(0x080A32)
        
        self.view.addSubview(buttonBarView)
//        self.lineView = PagerTabStriButtonBarViewDecorator(view: buttonBarView)
        buttonBarView.isScrollEnabled = false
        buttonBarView.selectedBar.isHidden = true
        buttonBarView.backgroundColor = HDA(0x080A32)
        buttonBarView.size = CGSize(width: ScreenWidth, height: buttonBarHeight)
        buttonBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(buttonBarHeight)
        }
        
        let line = UIView(.white)
        self.view.addSubview(line)
        line.cornerRadius = 2
        line.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(buttonBarView).offset(-9)
            make.size.equalTo(CGSize(width: 40, height: 4))
        }
         
        if let interactivePopGestureRecognizer = Router.currentNavigator?.interactivePopGestureRecognizer {
            containerView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer);
        }
    }
}




extension IndicatorInfo {

    fileprivate init(title: String, type: SendTokenCommitPageBarCell.Types) {
        self.init(title: title)
        self.userInfo = type
    }

    fileprivate var type: SendTokenCommitPageBarCell.Types? {
        return userInfo as? SendTokenCommitPageBarCell.Types
    }
}

extension SendTokenCommitRecentPageListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Recents"), type: .recent)
    }
}

extension SendTokenCommitMinePageListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Mine"), type: .mine)
    }
}


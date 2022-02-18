//
//  TokenInfoPageViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class TokenInfoPageViewController: BaseButtonBarPagerTabStripViewController<TokenInfoPageBarCell>, UICollectionViewDelegateFlowLayout {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.viewModel = ViewModel(wallet: wallet, coin: coin)
//        self.dappList = TokenInfoDappListBinder(viewModel.dappListVM)
        self.socialList = TokenInfoSocialListBinder(viewModel.socialListVM)
        self.addressList = TokenInfoAddressListBinder(viewModel.addressListVM)
        self.historyList = TokenInfoHistoryListBinder(viewModel.historyListVM)
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.configuration()
        self.layoutUI()
    }
    
    let viewModel: ViewModel
//    let dappList: TokenInfoDappListBinder
    let socialList: TokenInfoSocialListBinder
    let addressList: TokenInfoAddressListBinder
    let historyList: TokenInfoHistoryListBinder
    var listControllers: [TokenInfoSubListBinder] { [addressList, historyList, socialList] }
    private var lineView: PagerTabStriButtonBarViewDecorator?
    
    var buttonBarHeight: CGFloat { TokenInfoSubListBinder.topEdge }
    
    func refresh() {
        viewModel.refresh()
    }
    
    func viewWillAppear() {
        addressList.refresh()
    }
    
    private func didMove(to index: TokenInfoPageBarCell?) {
        guard let type = index?.type else { return }
        
        switch type {
//        case .dapp:
//            dappList.refresh()
        case .address:
            addressList.refresh()
        case .social:
            socialList.refresh()
        case .history:
            historyList.refresh()
        default: break
        }
    }
    
    //MARK: BaseButtonBarPagerTabStripViewController
//    override func setDefaultCurrentIndex() -> Int { return 0 }
    let itemWidth = ScreenWidth * 0.3333
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let w = (ScreenWidth - itemWidth) * 0.5
        return UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] { return listControllers }
    
    override func configure(cell: TokenInfoPageBarCell, for indicatorInfo: IndicatorInfo) {
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
        changeCurrentIndexProgressive = {[weak self](oldCell: TokenInfoPageBarCell?, newCell: TokenInfoPageBarCell?,
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




//MARK: Extension Of XLPagerTabStrip
extension IndicatorInfo {
    
    fileprivate init(title: String, type: TokenInfoPageBarCell.Types) {
        self.init(title: title)
        self.userInfo = type
    }
    
    fileprivate var type: TokenInfoPageBarCell.Types? {
        return userInfo as? TokenInfoPageBarCell.Types
    }
}

extension TokenInfoAddressListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Address"), type: .address)
    }
}

extension TokenInfoDappListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Token.Discover"), type: .dapp)
    }
}

extension TokenInfoSocialListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Token.Discover"), type: .social)
    }
}

extension TokenInfoHistoryListBinder: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Token.History"), type: .history)
    }
}

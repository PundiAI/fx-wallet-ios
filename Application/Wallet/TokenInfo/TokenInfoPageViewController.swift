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

class TokenInfoPageViewController: BaseButtonBarPagerTabStripViewController<TokenInfoPageBarCell> {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.viewModel = ViewModel(wallet: wallet, coin: coin)
//        self.dappList = TokenInfoDappListBinder(viewModel.dappListVM)
        self.socialList = TokenInfoSocialListBinder(viewModel.socialListVM)
        self.addressList = TokenInfoAddressListBinder(viewModel.addressListVM)
        super.init(nibName: nil, bundle: nil)
        
        self.logWhenDeinit()
        
        self.configuration()
        self.layoutUI()
    }
    
    let viewModel: ViewModel
//    let dappList: TokenInfoDappListBinder
    let socialList: TokenInfoSocialListBinder
    let addressList: TokenInfoAddressListBinder
    var listControllers: [TokenInfoSubListBinder] { [addressList, socialList] }
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
        default: break
        }
    }
    
    //MARK: BaseButtonBarPagerTabStripViewController
//    override func setDefaultCurrentIndex() -> Int { return 0 }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] { return listControllers }
    
    override func configure(cell: TokenInfoPageBarCell, for indicatorInfo: IndicatorInfo) {
        cell.bind(indicatorInfo)
    }
    
    
    
    private func configuration() {
        
        settings.style.buttonBarHeight = 0
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarLeftContentInset = 5
        settings.style.buttonBarRightContentInset = 5
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        
        buttonBarItemSpec = ButtonBarItemSpec.cellClass(width: { _ in (ScreenWidth - 160) / 5 })
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
        self.lineView = PagerTabStriButtonBarViewDecorator(view: buttonBarView)
        buttonBarView.backgroundColor = HDA(0x080A32)
        buttonBarView.size = CGSize(width: ScreenWidth - 100, height: buttonBarHeight)
        buttonBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(buttonBarHeight)
        }
        
        // Tab滚动效果
        containerView.rx.contentOffset.subscribe(onNext: {[weak self] point in
            self?.tabProgress(offset: point)
        }).disposed(by: defaultBag)
        
        // 边缘手势返回 冲突解决
        if let interactivePopGestureRecognizer = Router.currentNavigator?.interactivePopGestureRecognizer {
            containerView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer);
        }
    }
    
    private func tabProgress(offset:CGPoint) {
        let pageIndex =  self.pageFor(contentOffset: offset.x)
        let pageWidth = self.pageWidth
//        let minSacel:CGFloat = 0.8
//        let minColorAlpha:CGFloat = 0.2
//        let textColorBlock:(CGFloat) ->UIColor = { _sacel in
//            let alpha =  1 - ((1 - _sacel) * minSacel / minColorAlpha)
//            return HDA(0x080A32).withAlphaComponent(alpha)
//        }
//         
//        let setCellBlock:(CGFloat, Int, DappPageButtonBarCell) ->Void = {[weak self] _offsetX, _pageIndex , _cell in
//            let pageOffsetX = self?.pageOffsetForChild(at: _pageIndex) ?? 0
//            let distance = abs(_offsetX - pageOffsetX)
//            let sacel = min((1 - min((distance / pageWidth), 1)) * (1 - minSacel) + minSacel, 1)
//            _cell.textLabel.transform =  CGAffineTransform.identity.scaledBy(x: sacel, y: sacel)
//            _cell.textLabel.textColor = textColorBlock(sacel)
//        }
//        
//        if let pageTabCell = buttonBarView.cellForItem(at: IndexPath(row: pageIndex, section: 0)) as? DappPageButtonBarCell {
//            setCellBlock(offset.x, pageIndex, pageTabCell)
//            
//            if let pageTabCell_1 = buttonBarView.cellForItem(at: IndexPath(row: pageIndex + 1, section: 0) ) as? DappPageButtonBarCell  {
//                setCellBlock(offset.x, pageIndex+1, pageTabCell_1)
//            }
//            
//            if pageIndex - 1 >= 0 , let pageTabCell_0 = buttonBarView.cellForItem(at: IndexPath(row: pageIndex - 1, section: 0) ) as? DappPageButtonBarCell  {
//                setCellBlock(offset.x, pageIndex-1, pageTabCell_0)
//            }
//        }
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

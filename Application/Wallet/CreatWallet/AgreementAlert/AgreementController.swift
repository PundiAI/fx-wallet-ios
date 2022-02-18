

import WKKit
import RxSwift
import RxCocoa
import HDWalletKit
import TrustWalletCore
import Hero
import pop
import Macaw

struct AgreementCache {
    static private var db: UserDefaults { .standard }
    static private var Cache_Key:String { "fxWallet.Agreement.Cache.1" }
    static var content:Data? {
        get { db.data(forKey: Cache_Key) }
        set { db.setValue(newValue, forKey: Cache_Key)  }
    }
    
    static func request() ->Observable<String> {
        return Observable.create { (observer) -> RxSwift.Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if let content = AgreementCache.content {
                        observer.onNext(content)
                    } else {
                        if let url = Bundle.main.url(forResource: "Agreement", withExtension: "html"),
                           let content = try String(contentsOf: url, encoding: String.Encoding.utf8).data {
                            observer.onNext(content)
                        }
                    }
                    
                    if let url = URL(string: ThisAPP.WebURL.termServiceURL) {
                        let content = try Data(contentsOf: url)
                        observer.onNext(content)
                        AgreementCache.content = content
                        observer.onCompleted()
                    }
                } catch { }
            }
            
            return Disposables.create { }
        }.map { (data) -> String in
            return String(data: data, encoding: .utf8) ?? ""
        }.observeOn(MainScheduler.instance)
    }
}


extension AgreementViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let handler = context["handler"] as? (Bool) -> Bool else { return nil }
        let state = context["state"] as? Bool ?? false
        return AgreementViewController(handler: handler, state: state)
    }
}


class AgreementViewController: FxPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    let handler:(Bool) -> Bool
    var state:Bool = false
    
    init(handler: @escaping (Bool) -> Bool, state:Bool = false) {
        self.handler = handler
        self.state = state
        
        super.init(nibName: nil, bundle: nil) 
        self.bindHero()
    }
    
    override func getView() -> BaseView  {
        return super.getView().then {
            $0.listView.isHidden = true
            $0.mainView.border(Color.clear, 0).snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(80.auto())
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(320)
            }
            
            _ = $0.mainView.screen(.notFull)?
                           .cornerRadius(36.auto(), [.topLeft, .topRight])
        }
    }
    
    lazy var contentView = ContentView(frame: CGRect.zero)
    
    override var dismissWhenTouch: Bool { false }
    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true } 
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTitleView()
        bindContentView() 
        bindHero()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Action
    internal override func bindAction() {
        super.bindAction()
        contentView.submitButton.rx
            .tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if self?.handler(true) ?? false {
                    self?.dismiss(userCanceled: false,animated: true, completion: nil)
                }
            }).disposed(by: defaultBag)
    }
    
    var navBarHeight: CGFloat { wk.view.navBarHeight }
    func bindContentView() {
        wk.view.mainView.contentView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(navBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        contentView.agreeView.checkBoxState.accept(state)
    }
     
    func regexPattern(source:String, template:String, pattern:String) ->String {
        var finalString = source
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            finalString = regex.stringByReplacingMatches(in: finalString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                                         range: NSMakeRange(0, finalString.count), withTemplate: template)
        } catch { }
        return finalString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadHtml()
    }
    
    private func loadHtml() {
        let fontName:String = "CashMarket-MediumRounded"
        let fontFileName:String = "cash-market-rounded-medium.ttf"
        AgreementCache.request().subscribe(onNext: {[weak self] html in
            let pattern = "(?s)<style>.*?<\\/style>"
            let template = """
                          <style>
                            @font-face {
                                font-family: '\(fontName)';
                                src: local('\(fontName)'),url('\(fontFileName)') format('opentype');
                            }
                            body {
                                width: 80%;
                                margin-left: auto;
                                margin-right: auto;
                            }
                            h1 {
                                text-align: center;
                            }
                            h1, h4, h3, p {
                                font-family: '\(fontName)';
                                color: rgb(141, 142, 158);
                            }
                            a {
                                color: rgb(141, 142, 158);
                            }
                          </style>
                        """
            
            let newHtml = self?.regexPattern(source: html, template: template, pattern: pattern) ?? html 
            self?.contentView.webview.loadHTMLString(newHtml, baseURL: nil)
        }).disposed(by: defaultBag)
    }
    
    func bindTitleView() {
        let titleLabel = wk.view.navBar.titleLabel
        titleLabel.textColor = .white
        titleLabel.font = XWallet.Font(ofSize: 20, weight: .bold)
        titleLabel.text = TR("Agreement.Title")
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self, animated: animated, completion: completion)
    }
}

/// Hero
extension AgreementViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case (_, "AgreementViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ (_) in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers:[HeroModifier] = [.scale(0.8), .useGlobalCoordinateSpace,
                                            .useOptimizedSnapshot,
                                            .translate(y: 1000)]
            
            welf?.wk.view.mainView.hero.modifiers = modifiers
        }, onSuspend: { (_) in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.mainView.hero.modifiers = nil 
        })
        animators["0"] = animator
    }
}


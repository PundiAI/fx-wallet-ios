import WKKit
extension SetCurrencyViewController {
    class View: UIView {
        lazy var listView = WKMTableView(frame: ScreenBounds, style: .plain)

        lazy var indexBar = TTIndexBar(frame: CGRect(x: ScreenWidth - 30, y: 0, width: 30, height: ScreenHeight))
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .clear
            listView.backgroundColor = .white
            indexBar?.selectedBackgroundColor = COLOR.title
            indexBar?.selectedTextColor = .white
        }

        private func layoutUI() {
            addSubview(listView)
            listView.snp.makeConstraints { make in
                make.top.equalTo(FullNavBarHeight)
                make.bottom.left.right.equalToSuperview()
            }
            if let _indexBar = indexBar {
                addSubview(_indexBar)
            }
        }
    }
}

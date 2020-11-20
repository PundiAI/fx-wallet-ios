//
//  WKStackView.swift
//  XWallet
//
//  Created by Pundix54 on 2020/11/4.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import RxSwift
import WKKit

extension UIView {
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }

    func width(constant: CGFloat) {
        setConstraint(value: constant, attribute: .width)
    }

    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }

    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        let constraint =
            NSLayoutConstraint(item: self,
                               attribute: attribute,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: value)
        addConstraint(constraint)
    }
}

class WKScrollStackView: UIView {
    public lazy var scrollView: UIScrollView = {
        let instance = UIScrollView(frame: CGRect.zero)
        instance.layoutMargins = .zero
        return instance
    }()

    lazy var stackView: UIStackView = {
        var view = UIStackView()
        view.backgroundColor = UIColor.lightGray
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
        bind()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    private func bind() {
        stackView.rx.observe(CGRect.self, #keyPath(UIView.bounds))
            .subscribe(onNext: { print("frame: \($0!)") })
            .disposed(by: defaultBag)
    }
}

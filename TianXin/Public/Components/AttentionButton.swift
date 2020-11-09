//
//  AttentionButton.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AttentionButton: UIControl {
    var title = "关注"
    var attentionTitle = "已关注"
    // 是否已关注
    var isAttented: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    lazy private var iconView: UIImageView = {
        let iconView = UIImageView(image: R.image.icon_guanzhu())
        addSubview(iconView)
        return iconView
    }()
    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = self.height / 2.0
        
        self.iconView.size = .init(width: 15, height: 10)
        self.iconView.center.y = self.height / 2.0
        self.iconView.x = 8
        if isAttented {
            self.iconView.width = 0
            self.iconView.isHidden = true
            self.label.text = attentionTitle
            self.label.textColor = .white
            self.backgroundColor = .lightGray
            self.label.sizeToFit()
            self.label.center.x = self.width / 2.0
            self.borderWidth = 0
        } else {
            self.iconView.width = 15
            self.iconView.isHidden = false
            self.label.text = title
            self.label.textColor = Configs.Theme.Color.primary
            self.backgroundColor = .white
            self.label.sizeToFit()
            self.label.x = self.iconView.frame.maxX + 2
            self.borderWidth = 1
        }
        self.label.center.y = self.height / 2.0
    }

    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        switch controlEvents {
        case .touchUpInside:
            self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
        default: break
        }
        
    }
}

extension Reactive where Base: AttentionButton {
    var isAttented: Binder<Bool> {
        return Binder<Bool>(self.base) {
            view, isAttented in
            view.isAttented = isAttented
        }
    }
}

extension Reactive where Base: AttentionButton {
    var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

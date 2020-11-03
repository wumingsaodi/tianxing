//
//  KOKMenuItem.swift
//  TianXin
//
//  Created by pretty on 10/22/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class KOKMenuItem: UIControl {
    lazy var backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return imgView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp_bottomMargin).offset(10)
            make.centerX.equalToSuperview()
        }
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        addSubview(v)
        v.snp.makeConstraints { make in
//            make.width.height.equalToSuperview().multipliedBy(0.4)
            make.width.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bringSubviewToFront(backgroundImageView)
        bringSubviewToFront(imageView)
        bringSubviewToFront(titleLabel)
        isSelected = false
    }
    
    @IBInspectable
    override var isSelected: Bool {
        didSet {
            titleLabel.text = title
            if isSelected {
                backgroundImageView.image = selectedBackgroundImage
                imageView.image = selectedImage
                titleLabel.textColor = titleSelectedColor
            } else {
                backgroundImageView.image = normalBackgroundImage
                imageView.image = normalImage
                titleLabel.textColor = titleColor
            }
        }
    }

    @IBInspectable
    var normalBackgroundImage: UIImage?
    @IBInspectable
    var selectedBackgroundImage: UIImage?
    @IBInspectable
    var normalImage: UIImage?
    @IBInspectable
    var selectedImage: UIImage?
    @IBInspectable
    var title: String?
    @IBInspectable
    var titleColor: UIColor?
    @IBInspectable
    var titleSelectedColor: UIColor?
}

extension Reactive where Base: KOKMenuItem {
    var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

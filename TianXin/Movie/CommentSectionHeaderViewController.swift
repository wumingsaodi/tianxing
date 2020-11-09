//
//  CommentHeaderViewController.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentSectionHeaderViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortedWayLabel: UILabel!
    
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTrailingConstraint: NSLayoutConstraint!
    
    var text: BehaviorRelay<String>? {
        didSet {
            text?.asDriver().drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        }
    }
    
    var horizontalSpacing: CGFloat  = 0 {
        willSet {
            contentViewLeadingConstraint.constant = newValue
            contentViewTrailingConstraint.constant = newValue
        }
    }
    
    func bind(_ title: String) {
        titleLabel.text = title
        sortedWayLabel.isHidden = title.contains("精选")
    }
    
}

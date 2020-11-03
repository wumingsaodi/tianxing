//
//  SearchBarViewController.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SearchBarViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.setPlaceholder(font: .systemFont(ofSize: 13), color: Configs.Theme.Color.grey)
        
        textField.rx.text.orEmpty
            .map{!$0.isEmpty}
            .bind(to: searchButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }
}

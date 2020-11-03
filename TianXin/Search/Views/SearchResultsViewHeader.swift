//
//  SearchResultsViewHeader.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class SearchResultsViewHeader: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    func bind(_ text: String) {
        label.text = text
    }
}

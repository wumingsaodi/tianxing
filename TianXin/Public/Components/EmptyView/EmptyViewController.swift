//
//  EmptyViewController.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var text: String?
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        label.text = text
    }
}
extension EmptyViewController {
    static func create(withImage image: UIImage? = nil, title: String? = nil) -> EmptyViewController {
        let vc = EmptyViewController.instanceFrom(storyboard: "Empty")
        vc.image = image ?? R.image.nodata()
        vc.text = title
        return vc
    }
}

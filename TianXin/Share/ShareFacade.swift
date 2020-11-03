//
//  ShareFacade.swift
//  TianXin
//
//  Created by pretty on 10/29/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class ShareFacade {
    static func share(url: URL = Configs.App.shareURL, title: String = Configs.App.shareName, image: UIImage? = nil) {
        var activityItems: [Any] = [url, title]
        if let image = image {
            activityItems.append(image)
        }
        let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        getCurrentViewController()?.present(activity, animated: true)
    }
}


func getCurrentViewController() -> UIViewController? {
    guard let window = UIApplication.shared.keyWindow else { return nil }
    if let tabVc = window.rootViewController as? UITabBarController,
       let navc = tabVc.selectedViewController as? UINavigationController {
        return navc.topViewController
    }
    if let navc = window.rootViewController as? UINavigationController {
        return navc.topViewController
    }
    return window.rootViewController
}

//
//  UITableView.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

extension UITableView {
    func registerClass<T:UITableViewCell>(type:T.Type){
        register(type, forCellReuseIdentifier: "\(type)")
    }
    func registerNib<T: UITableViewCell>(type: T.Type) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forCellReuseIdentifier: "\(type)")
    }
    func registerHeaderFooterViewNib<T: UITableViewHeaderFooterView>(type: T.Type) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(type)")
    }
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as! T
    }
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: "\(T.self)") as! T
    }
}

extension UITableViewCell {
    var indexPath: IndexPath? {
        return (self.superview as? UITableView)?.indexPath(for: self)
    }
    var isLast: Bool {
        guard let tableView = self.superview as? UITableView,
              let indexPath = self.indexPath,
              let numbers = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section)
              else { return false }
        return  numbers - 1 == indexPath.row
    }
}

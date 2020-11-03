//
//  KOKHomeViewController.swift
//  TianXin
//
//  Created by pretty on 10/22/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KOKHomeViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let items = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        calculateHeaderHeight()
        calculateCellHeight()
        providerItems()
        
        items.asDriver().drive(tableView.rx.items(cellIdentifier: "\(KOKGameHallCell.self)", cellType: KOKGameHallCell.self)){
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: rx.disposeBag)
        
        backButton.rx.tap
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    // 根据背景图计算cell高度，以防止图片缩放失真
    private func calculateCellHeight() {
        // table view cell height
        let cellWidth = Configs.Dimensions.screenWidth - 40
         // 图片比例 676: 175
        let cellHeight = ceil(cellWidth * 175 / 676) + 12.5
        tableView.rowHeight = cellHeight
    }
    private func calculateHeaderHeight() {
        let width = Configs.Dimensions.screenWidth
        let height = ceil(width * 348 / 750)
        tableView.tableHeaderView?.height = height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension KOKHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
}

extension UIViewController {
    func showKOK() {
        let vc = KOKHomeViewController.instanceFrom(storyboard: "Kok")
        self.show(vc, sender: self)
    }
}


extension KOKHomeViewController {
    private func providerItems() {
        items.accept(["img_tiyu", "img_zhenren", "img_dianjing", "img_caipiao", "img_qipai", "img_dianzi"])
    }
}

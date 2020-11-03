//
//  TopicViewController.swift
//  TianXin
//
//  Created by pretty on 10/7/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import NSObject_Rx
import RxDataSources
import MJRefresh

class TopicViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kokButton: UIButton!
    
    lazy var viewModel = TopicViewControllerModel()
    let headerRefreshTrigger = PublishSubject<Void>()
    let isHeaderLoading = BehaviorRelay(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()

        tableView.tableFooterView = UIView()
        tableView.registerNib(type: TopicListCell.self)
//        tableView.registerHeaderFooterViewNib(type: TableViewSectionHeaderView.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
    
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = TopicViewControllerModel.Input(
            headerRefresh: refresh,
            selection: tableView.rx.modelSelected(TopicViewCellViewModel.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        output.items
            .drive(tableView.rx.items(cellIdentifier: "TopicListCell", cellType: TopicListCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
        
        output.selected.drive(onNext: {[weak self] item in
            let vc = MovieListOnTopicViewController.instanceFrom(storyboard: "Topic")
            vc.viewModel = MovieListOnTopicViewControllerModel(topic: item.topic)
            self?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
        }).disposed(by: rx.disposeBag)
        
        // 点击logo
        kokButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] _ in
                self?.showKOK()
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !kAppdelegate.islogin() {
            return false
        }
        return true
    }
    
    func makeUI() {
        if #available(iOS 11.0, *) {
            navigationItem.backButtonTitle = ""
        } else {
            navigationItem.backBarButtonItem?.title = ""
        }
    }
    
    @IBAction func onSearch(_ sender: UITapGestureRecognizer) {
        navigationController?.pushViewController(
            SearchViewController.instanceFrom(storyboard: "Search"),
//            HomeDetailVC(coverUrl: ""),
            isNeedLogin: true,
            animated: true
        )
    }
}

extension TopicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        if v == nil {
            v = TableViewSectionViewController.instanceFrom(storyboard: "Topic").view as? UITableViewHeaderFooterView
            v?.width = tableView.frame.width
            v?.height = 40
        }
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension TopicViewController {
    static var instance: TopicViewController {
        return UIStoryboard(name: "Topic", bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! TopicViewController
    }
}

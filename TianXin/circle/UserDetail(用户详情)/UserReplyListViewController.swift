//
//  UserReplyListViewController.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class UserReplyListViewController: UIViewController, ScrollViewSimultaneouslable {
    @IBOutlet weak var tableView: UITableView!
    var canScroll: Bool = false
    var isRefresh = true
    let superCanScroll = PublishSubject<Bool>()
    var firstLoad: Bool = true
    
    var viewModel: UserReplyListViewControllerModel?
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation, self.view.rx.hudShown).disposed(by: rx.disposeBag)
        isFooterLoading.bind(to: tableView.rx.isLodingData).disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        guard let vm = viewModel else { return }
        vm.isHeaderLoding.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        vm.isFooterLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        vm.noMoreData.asObservable().bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        
        let headerRefresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = UserReplyListViewControllerModel.Input(
            headerRefresh: headerRefresh,
            footerRefresh: footerRefreshTrigger
        )
        let output = vm.transform(input: input)
        output.items.map{$0.isEmpty}.drive(onNext: {[weak self] isEmpty in
            self?.firstLoad = isEmpty
        }).disposed(by: rx.disposeBag)
        tableView.dataSource = nil
        output.items.drive(tableView.rx.items(cellIdentifier: "\(UserReplyListCell.self)", cellType: UserReplyListCell.self)){
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: rx.disposeBag)
        // cell 点击
        tableView.rx.modelSelected(UserReplyListCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = IssueDetailViewController.`init`(withIssueId: model.json.issueId.string)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
    }

}
extension UserReplyListViewController: UserDetailDataControllable {
    func relaodData() {
        if !firstLoad {
            return
        }
        firstLoad = false
        bindViewModel()
    }
}

extension UserReplyListViewController: UITableViewDelegate {}
extension UserReplyListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isRefresh {
            return
        }
        if !self.canScroll {
            self.tableView.contentOffset.y = 0
        } else {
            if self.tableView.contentOffset.y <= 0  {
                self.canScroll = false
                self.superCanScroll.onNext(true)
            }
        }
    }
}

//
//  UserPublishListViewController.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

// 发布、收藏、足迹
class UserPublishListViewController: UIViewController, ScrollViewSimultaneouslable {
    @IBOutlet weak var tableView: UITableView!
    var canScroll: Bool = false
    var isRefresh = true
    var firstLoad: Bool = true
    
    var viewModel: UserPublishListViewControllerModel?
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: false)
    
    let itemsCount = PublishSubject<Int>()
    let superCanScroll = PublishSubject<Bool>()
    // 帖子点赞
    let likeEvent = PublishSubject<Bool>()
    // 查看帖子详情
    let viewIssueEvent = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        isFooterLoading.bind(to: tableView.rx.isLodingData).disposed(by: rx.disposeBag)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }
}

extension UserPublishListViewController: UserDetailDataControllable {
    // 如果数据为空，下次调用也被视为首次
    func relaodData() {
        assert(self.viewModel != nil, "UserPublishListViewController 未设置数据源")
        
        guard let viewModel = self.viewModel else { return }
        if !firstLoad {
            return
        }
        firstLoad = false
        viewModel.isHeaderLoding.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.isFooterLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.asObservable().bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        viewModel.isLoding.asObservable().bind(to: self.view.rx.hudShown).disposed(by: rx.disposeBag)
        viewModel.errMsg.asObservable().bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        
        let headerRefresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = UserPublishListViewControllerModel.Input(
            headerRefresh: headerRefresh,
            footerRefresh: footerRefreshTrigger
        )
        
        let output = viewModel.transform(input: input)
        // assert(proxy._forwardToDelegate() === nil)
        tableView.dataSource = nil
        output.items.drive(tableView.rx.items(cellIdentifier: "\(UserPublishListCell.self)", cellType: UserPublishListCell.self)){
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: rx.disposeBag)
        
        output.items.map{$0.isEmpty}.drive(onNext: {[weak self] isEmpty in
            self?.firstLoad = isEmpty
        }).disposed(by: rx.disposeBag)
            
        // 点击cell 和点击评论按钮，跳转到帖子详情
        Observable.of(
            tableView.rx.modelSelected(UserPublishIssueItemViewModel.self).map{"\($0.item.issueId)"}.asObservable(),
            output.onTapComment.asObservable()
        ).merge()
        .subscribe(onNext: { [weak self] issueId in
            let vc = IssueDetailViewController.`init`(withIssueId: issueId)
            self?.show(vc, sender: self)
        }).disposed(by: rx.disposeBag)
        
    }
}

extension UserPublishListViewController {
    enum DataType {
        case 发布
        case 收藏
        case 足迹
    }
}

extension UserPublishListViewController: UITableViewDelegate {}
extension UserPublishListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isRefresh {
            return
        }
        if !self.canScroll {
            self.tableView.contentOffset.y = 0
        } else {
            if self.tableView.contentOffset.y <= 0 {
                self.canScroll = false
                self.superCanScroll.onNext(true)
            }
        }
    }
}

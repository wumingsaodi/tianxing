//
//  CommentReplyViewController.swift
//  TianXin
//
//  Created by pretty on 10/13/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class CommentReplyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: CommentReplayViewControllerModel!
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    let isHeaderLoading = BehaviorRelay(value: false)
    
    var headerViewController: CommentDetailHeaderViewController? {
        return children.first { $0 is CommentDetailHeaderViewController } as? CommentDetailHeaderViewController
    }
    var inputController: ReplyInputViewController? {
        return children.first { $0 is ReplyInputViewController } as? ReplyInputViewController
    }
    
    var headerText = BehaviorRelay<String>(value: "")
    fileprivate let reload = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "评论详情"
        assert(viewModel != nil, "viewModel is nil")
        tableView.configureDataSetView(options: [.empty: "暂无回复"], isFullScreen: false)
        tableView.registerNib(type: CommentCell.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.shadowImage = try? UIImage(color: .clear)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter {
            [weak self] in
            self?.footerRefreshTrigger.onNext(())
        }
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.noMoreData.asObservable().bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        viewModel.reload.asObserver().bind(to: self.reload).disposed(by: rx.disposeBag)
        let headerRefresh = Observable.of(Observable.just(()), headerRefreshTrigger, self.reload.asObservable()).merge()
        let input = CommentReplayViewControllerModel.Input(
            headerRefresh: headerRefresh,
            footerRefresh: footerRefreshTrigger,
            cellSelected: tableView.rx.modelSelected(CommentReplyViewModel.self).asObservable(),
            tapComment: headerViewController!.tap,
            reply: inputController!.replyEvent
        )
        let output = viewModel.transform(input: input)
        // input controller
        inputController?.bind(output.currentReplyTarget)
        
        headerViewController?.bind(
            CommentViewModel(viewModel.comment),
            isAttention: output.isAttention,
            likeCount: output.commentLikeCount
        )
        
        output.items.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "\(CommentCell.self)", cellType: CommentCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
        
        output.items.map { $0.isEmpty ? UIView.LoadDataState.empty : .none }.asDriver()
            .drive(tableView.rx.loadDataState).disposed(by: rx.disposeBag)
        
        output.items.drive(onNext: { [weak self] items in
            self?.headerText.accept("全部回复（\(items.count)）")
        }).disposed(by: rx.disposeBag)
        
        output.items.map{$0.isEmpty}.drive(tableView.rx.hiddenRefreshFooter).disposed(by: rx.disposeBag)
    }

}

extension CommentReplyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        if v == nil {
            let vc = CommentSectionHeaderViewController.instanceFrom(storyboard: "Movie")
            v = vc.view as? UITableViewHeaderFooterView
            v?.width = tableView.frame.width
            v?.height = 44
            vc.text = self.headerText
        }
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

//
//  IssueCommentReplyViewController.swift
//  TianXin
//
//  Created by pretty on 10/20/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import PKHUD

class IssueCommentReplyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var headerViewController: IssueCommentReplyHeaderViewController = {
        return children.first { $0 is IssueCommentReplyHeaderViewController } as! IssueCommentReplyHeaderViewController
    }()
    
    lazy var replyInputViewController: ReplyInputViewController = {
        return children.first { $0 is ReplyInputViewController} as! ReplyInputViewController
    }()
    
    var viewModel: IssueCommentReplyViewControllerModel?
    var replyNum = BehaviorRelay<Int>(value: 0)
    
    private let headerRefreshTrigger = PublishSubject<Void>()
    private let footerRefreshTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "评论详情"
        tableView.tableFooterView = UIView()
        tableView.configureDataSetView(options: [.empty: "暂无回复"], isFullScreen: false)
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        tableView.registerNib(type: IssueReplyCell.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        bindViewModel()
        
        headerViewController.height.asObservable()
            .bind(to: tableView.rx.headerHeight)
            .disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        guard let vm = viewModel else { return }
        vm.errorMsg.bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        vm.headerLoading.drive(self.view.rx.hudShown).disposed(by: rx.disposeBag)
        vm.noMoreData.asObservable().bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        vm.headerLoading.asObservable().bind(to: tableView.rx.isLodingData).disposed(by: rx.disposeBag)
        
        let reload = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let tapToUser = Observable.of(
            tableView.rx.modelSelected(IssueReplyItemViewModel.self)
                .filter({ item in
                    if item.issueReply.userId == LocalUserInfo.share.userId {
                        HUD.flash(.label("您不能回复自己的回复"), delay: 1.5)
                        return false
                    }
                    return true
                })
                .map{(
                "\($0.issueReply.userId ?? 0)", // to userid
                "2",
                "\($0.issueReply.replyId ?? 0)",
                $0.issueReply.nickName ?? $0.issueReply.userName ?? ""
            )},
            headerViewController.onTap.asObservable()
        ).merge()
        let input = IssueCommentReplyViewControllerModel.Input(
            reload: reload,
            footerRefresh: footerRefreshTrigger,
            replyToUser: tapToUser,
            onReply: replyInputViewController.replyEvent,
            onLike: headerViewController.onLike,
            onAttention: headerViewController.onAttention
        )
        let output = vm.transform(input: input)
        headerViewController.bind(comment: output.issueComment, isLiked: output.isRmkLike, likeNum: output.issueRemkLikeCount)
        replyInputViewController.bind(output.replyToUserName.asDriver(onErrorJustReturn: ""))
        output.replyItems
            .drive(tableView.rx.items(cellIdentifier: "\(IssueReplyCell.self)", cellType: IssueReplyCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }
            .disposed(by: rx.disposeBag)
        output.commentNum.drive(replyNum).disposed(by: rx.disposeBag)
        // 点击头像
        output.tapUser.subscribe(onNext: { [weak self] userId in
            if LocalUserInfo.share.userId?.toString() == userId {
                return
            }
            let vc = UserDetailViewController.`init`(withUserId: userId)
            self?.show(vc, sender: self)
        }).disposed(by: rx.disposeBag)
        
        vm.errorMsg.asObservable().bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        
    }
}

extension IssueCommentReplyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if replyNum.value == 0 {
            return 0
        }
        return 44
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let numberOfRows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section), numberOfRows > 0 else { return nil }
        var v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        if v == nil {
            let vc = CommentSectionHeaderViewController.instanceFrom(storyboard: "Movie")
            v = vc.view as? UITableViewHeaderFooterView
            v?.height = 44
            vc.bind("全部回复(\(replyNum.value))")
        }
        return v
    }
}

// MARK: - header
class IssueCommentReplyHeaderViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timaLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var attentionButton: AttentionButton!
    
    var height = PublishSubject<CGFloat>()
    
    var comment: Driver<IssueComment>?
    let onTap = PublishSubject<(String, String, String, String)>()
    let onLike = PublishSubject<Void>()
    let onAttention = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.rx.tapGesture()
            .when(.ended)
            .asObservable()
            .flatMapLatest({ [weak self] _ -> Observable<IssueComment?> in
                guard let comment = self?.comment else { return Observable.just(nil)}
                return comment.map{Optional($0)}.asObservable()
            })
            .filterNil()
            .subscribe(onNext: { [weak self] comment in
                if LocalUserInfo.share.userId == comment.userId {
                    return
                }
                let vc = UserDetailViewController.`init`(withUserId: "\(comment.userId)")
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        likeButton.rx.tap
            .bind(to: onLike)
            .disposed(by: rx.disposeBag)
        attentionButton.rx.tap
            .bind(to: onAttention)
            .disposed(by: rx.disposeBag)
    }
    
    func bind(comment: Driver<IssueComment>, isLiked: Driver<Bool>, likeNum: Driver<Int>) {
        self.comment = comment
        isLiked.drive(likeButton.rx.isSelected).disposed(by: rx.disposeBag)
        likeNum.map{"\($0)"}.drive(likeButton.rx.title()).disposed(by: rx.disposeBag)
        comment.map { $0.isAttention == 1 }.drive(attentionButton.rx.isAttented).disposed(by: rx.disposeBag)
        comment.map { $0.createTime }.drive(timaLabel.rx.text).disposed(by: rx.disposeBag)
        comment.map { $0.nickName ?? $0.userName }.drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        comment.map { try? $0.userLogo?.asURL() }.filterNil()
            .drive(avatarImageView.rx.imageURL).disposed(by: rx.disposeBag)
        comment.map { $0.remark }.drive(contentLabel.rx.text).disposed(by: rx.disposeBag)
        comment.map { $0.userId == LocalUserInfo.share.userId}.asDriver()
            .drive(attentionButton.rx.isHidden).disposed(by: rx.disposeBag)
        
        comment.map { $0.remark }
            .filterNil()
            .map{[weak self] in
                guard let self = self else { return 0 }
                let label = UILabel()
                label.font = self.contentLabel.font
                label.numberOfLines = 0
                label.text = $0
                let height = label.sizeThatFits(.init(width: self.contentLabel.width, height: CGFloat.greatestFiniteMagnitude)).height
//                let height = ($0 as NSString)
//                    .boundingRect(with: .init(width: self.contentLabel.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading], attributes: [.font: self.contentLabel.font!], context: nil).size.height
                return ceil(height) + 140}
            .drive(height)
            .disposed(by: rx.disposeBag)
        
        
        Observable.just(())
            .flatMapLatest({ _ -> Observable<IssueComment> in
                return comment.asObservable()
            })
            .map{("\($0.userId)", "1", "\($0.remarkId)", $0.nickName ?? $0.userName ?? "")}
            .bind(to: onTap)
            .disposed(by: rx.disposeBag)
        
        self.view.rx.tapGesture()
            .when(.ended)
            .flatMapLatest({ _ -> Observable<IssueComment> in
                return comment.asObservable()
            })
            .filter({ comment in
                if LocalUserInfo.share.userId == comment.userId {
                    HUD.flash(.label("您不能回复自己的评论"), delay: 1.5)
                    return false
                }
                return true
            })
            .map{("\($0.userId)", "1", "\($0.remarkId)", $0.nickName ?? $0.userName ?? "")}
            .bind(to: onTap)
            .disposed(by: rx.disposeBag)
    }

}

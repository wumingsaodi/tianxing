//
//  IssueDetailViewController.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class IssueDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    var headerViewController: IssueDetailHeaderViewController? {
        return children.first{ $0 is IssueDetailHeaderViewController } as? IssueDetailHeaderViewController
    }
    var inputController: InputViewController? {
        return children.first {  $0 is InputViewController } as? InputViewController
    }
    
    var datasource: RxTableViewSectionedReloadDataSource<SectionModel<String, IssueCommentReplyItemViewModel>>?
    
    var viewModel: IssueDetailViewControllerModel?
    
    let footerRefreshTrigger = PublishSubject<Void>()
    let headerRefreshTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "详情"
        tableView.registerNib(type: CommentCell2.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        
        guard let viewModel = self.viewModel else { return }
        viewModel.isLoading.drive(self.view.rx.hudShown).disposed(by: rx.disposeBag)
        viewModel.isLoading.drive(tableView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        viewModel.errMsg.asDriverOnErrorJustComplete().drive(self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        viewModel.noMoreData.asDriverOnErrorJustComplete().drive(tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger.asObservable()).merge()
        let input = IssueDetailViewControllerModel.Input(
            refresh: refresh,
            footerRefresh: footerRefreshTrigger,
            onLike: Observable.of(inputController!.likeEvent.asObservable(), headerViewController!.onLike.asObservable()).merge(),
            onComment: inputController!.sendComment,
            onAttention: headerViewController!.onAttention,
            onFavorite: Observable.of(headerViewController!.onFavorite.asObservable(), inputController!.favoriteEvent.asObservable()).merge()
        )
        let output = viewModel.transform(input: input)
        
        headerViewController?.bind(output.detail)
        headerViewController?.bind(output.isLiked, output.isFavorited)
        inputController?.bind(output.isLiked, output.isFavorited)
        
        inputController?.tapCommentEvent
            .asObservable()
            .subscribe(onNext: {
                // TODO: - 不知道要干嘛
            })
            .disposed(by: rx.disposeBag)
        
        
        // 计算header height
        output.detail
            .map { [weak self] detail in
                let height = detail.issueVideo.isEmpty ?
                    (self?.headerViewController?.calculateHeight(itemCount:( detail.issuePic ?? []).count) ?? 0) :
                    (Configs.Dimensions.screenWidth - 48) * 9 / 16
                let circleListHeight: CGFloat = detail.joinRecommendList.isEmpty ? 0 : 25
                return height + 135 + (self?.calculateHeight(text: detail.issueContent ?? "") ?? 0) + circleListHeight
            }
            .drive(tableView.rx.headerHeight)
            .disposed(by: rx.disposeBag)
        
        datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, IssueCommentReplyItemViewModel>> {
            sectionData, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(for: indexPath) as CommentCell2
            cell.bind(item)
            return cell
        }
        Driver.combineLatest(output.topReplys, output.replys, output.commentNum)
            .map{[
                SectionModel(model: "精选评论(\($0.0.count))", items: $0.0),
                SectionModel(model: "全部评论(\($0.2))", items: $0.1),
            ]}
            .drive(tableView.rx.items(dataSource: datasource!))
            .disposed(by: rx.disposeBag)
        // 点击cell
        tableView.rx.modelSelected(IssueCommentReplyItemViewModel.self)
            .subscribe(onNext: { [weak self] model in
                let vc = IssueCommentReplyViewController.instanceFrom(storyboard: "Circle")
                vc.viewModel = IssueCommentReplyViewControllerModel(remarkId: "\(model.issueRemark.remarkId)")
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        // 点击头像
        output.tapUser.subscribe(onNext: { [weak self] userId in
            let vc = UserDetailViewController.`init`(withUserId: userId)
            self?.show(vc, sender: self)
        }).disposed(by: rx.disposeBag)
    }
}
 
extension IssueDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let numberOfRows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section), numberOfRows > 0 else { return nil }
        var v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        if v == nil {
            let vc = CommentSectionHeaderViewController.instanceFrom(storyboard: "Movie")
            v = vc.view as? UITableViewHeaderFooterView
            v?.height = 44
            vc.bind(datasource?.sectionModels[section].model ?? "")
            vc.horizontalSpacing = 12
        }
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let numberOfRows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section), numberOfRows > 0 else { return 0 }
        return 44
    }
}

extension IssueDetailViewController {
    fileprivate func calculateHeight(text: String) -> CGFloat {
        let size = (text as NSString).boundingRect(with: .init(width: Configs.Dimensions.screenWidth - 48, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.systemFont(ofSize: 18)], context: nil).size
        return size.height
    }
    
    static func `init`(withIssueId issueId: String) -> IssueDetailViewController {
        let vc = IssueDetailViewController.instanceFrom(storyboard: "Circle")
        vc.viewModel = IssueDetailViewControllerModel(issueId: issueId)
        return vc
    }
}


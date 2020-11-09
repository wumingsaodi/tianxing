//
//  MovieDetialViewController.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import MJRefresh

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoHeaderHeightConstraint: NSLayoutConstraint!
    
    var viewModel: MovieDetailViewControllerModel!
    
    lazy var playerController: MoviePlayerViewController? = {
        return children.first { $0 is MoviePlayerViewController } as? MoviePlayerViewController
    }()
    lazy var infoHeaderController: MovieInfoHeaderViewController? = {
        return children.first { $0 is MovieInfoHeaderViewController } as? MovieInfoHeaderViewController
    }()
    lazy var recommendController: MovieRecommendsViewController? = {
        return children.first { $0 is MovieRecommendsViewController } as? MovieRecommendsViewController
    }()
    lazy var inputController: InputViewController? = {
        return children.first { $0 is InputViewController } as? InputViewController
    }()
    
    fileprivate let headerText = BehaviorRelay<String>(value: "")
    fileprivate let likeComment = BehaviorRelay<String?>(value: nil)
    
    let footerRefreshTriggle = PublishSubject<Void>()
    let headerRefreshTriggle = PublishSubject<Void>()
    let reload = PublishSubject<Void>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        tableView.tableFooterView = UIView()
        infoHeaderController?.movie.accept(viewModel.movie)
        playerController?.movie = viewModel.movie
        
        tableView.tableFooterView?.configureDataSetView(options: [.empty: "暂无评论"])
        tableView.registerNib(type: CommentCell.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.backgroundColor = .white

        tableView.mj_header = MJRefreshNormalHeader() {[weak self] in
            self?.headerRefreshTriggle.onNext(())
        }
        tableView.mj_footer = MJRefreshAutoNormalFooter() { [weak self] in
            self?.footerRefreshTriggle.onNext(())
        }
        
        viewModel.noMoreData.bind(to: self.tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        viewModel.isLoding.asDriver().drive(self.tableView.rx.isLodingData).disposed(by: rx.disposeBag)
        
        
        let reload = Observable.of(Observable.just(()), headerRefreshTriggle.asObservable(), self.reload).merge()
        
        let input = MovieDetailViewControllerModel.Input(
            sendComment: inputController!.sendComment,
            reload: reload,
            footerRefresh: footerRefreshTriggle,
            likeMovie: Observable.of(inputController!.likeEvent.asObservable(), infoHeaderController!.likeMovie.asObservable()).merge(),
            favoriteMovie: Observable.of(inputController!.favoriteEvent.asObservable(), infoHeaderController!.favoriteMovie.asObservable()).merge()
        )
        let output = viewModel.transform(input: input)
        // 更新子控制器状态
        inputController?.bind(output.isLikeMovie, output.isFavoritedMovie)
        infoHeaderController?.bind(output.isLikeMovie, isFavorited: output.isFavoritedMovie, keywords: output.keywords, likeCount: output.likeCount)
//        infoHeaderController?.bind(output.movie)
        recommendController?.bind(output.recommends)
        let itemHeight = recommendController?.itemHeight ?? 0
        // 动态计算table view height
        Driver.combineLatest(output.recommends, output.keywords)
            .drive(onNext: { [weak self] recomends, keywords in
                let infoHeight: CGFloat = 70 + (keywords.isEmpty ? 0 : 44)
                self?.infoHeaderHeightConstraint.constant = infoHeight
                self?.view.layoutIfNeeded()
                let recomendHeight = 44 + CGFloat((recomends.count + 1) / 2) * itemHeight
                self?.tableView.tableHeaderView?.height = infoHeight + recomendHeight
                self?.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        // 渲染list
        output.comments
            .drive(tableView.rx.items(cellIdentifier: "\(CommentCell.self)", cellType: CommentCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel, likeEvent: nil)
            }.disposed(by: rx.disposeBag)
        // 处理table view footer
        output.comments.drive(onNext: { [weak self] items in
            self?.tableView.tableFooterView?.height = items.isEmpty ? 260 : 0
            self?.tableView.reloadData()
            self?.headerText.accept("全部评论（\(items.count)）")
        }).disposed(by: rx.disposeBag)
        output.comments.map { $0.isEmpty ? .empty : .none }.asDriver()
            .drive(self.tableView.tableFooterView!.rx.loadDataState)
            .disposed(by: rx.disposeBag)
        // 点击cell
        tableView.rx.modelSelected(CommentViewModel.self)
            .asDriver()
            .drive(onNext: { [weak self] comment in
                guard let self = self else { return }
                let vc = CommentReplyViewController.instanceFrom(storyboard: "Movie")
                vc.viewModel = CommentReplayViewControllerModel(comment: comment.comment)
                self.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        // 点击推荐cell
        recommendController?.itemSelected
            .asObservable()
            .subscribe(onNext: { [weak self] item in
                // 暂停当前播放
                self?.playerController?.pause()
                let vc = MovieDetailViewController.instanceFrom(storyboard: "Movie")
                vc.viewModel = MovieDetailViewControllerModel(movie: item.movie)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        // 没有数据隐藏mj_footer
        output.comments.map { $0.isEmpty }.drive(tableView.mj_footer!.rx.isHidden).disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension MovieDetailViewController: UITableViewDelegate {
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

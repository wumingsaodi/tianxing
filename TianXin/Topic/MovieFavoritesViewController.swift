//
//  MovieFavoritesViewController.swift
//  TianXin
//
//  Created by pretty on 10/9/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class MovieFavoritesViewController: UIViewController {
    @IBOutlet weak var bottomButtonItemsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()
    let error = PublishSubject<Error>()
    
    let isHeaderLoading = BehaviorRelay(value: false)
    // 是否开始编辑
    let xediting = BehaviorRelay(value: false)
    let selectAll = BehaviorRelay(value: false)
    // 批量删除
    let onDelete = PublishSubject<Void>()
    
    lazy var viewModel = MovieFavoritesViewControllerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configureDataSetView(options: [.empty: "暂无收藏"])
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.error.asObservable().bind(to: error).disposed(by: rx.disposeBag)
        
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = MovieFavoritesViewControllerModel.Input(
            headerRefresh: refresh,
            footerRefresh: footerRefreshTrigger,
            isEditing: xediting.asDriver(),
            selectAll: selectAll.asDriver(),
            onDelete: onDelete
        )
        let output = viewModel.transform(input: input)
        output.items
            .drive(tableView.rx.items(cellIdentifier: "\(MovieFavoritesCell.self)", cellType: MovieFavoritesCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
        output.items.map { $0.isEmpty ? UIView.LoadDataState.empty : UIView.LoadDataState.none }.asDriver()
            .drive(tableView.rx.loadDataState).disposed(by: rx.disposeBag)
        
        xediting.map { $0 ? "取消" : "编辑" }.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(navigationItem.rightBarButtonItem!.rx.title).disposed(by: rx.disposeBag)
        xediting.map { ($0 ? -34 : -123) as CGFloat }.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(bottomButtonItemsBottomConstraint.rx.animationConstant).disposed(by: rx.disposeBag)
        error.subscribe(onNext: { error in
            SDSHUD.showError(error.localizedDescription)
        }).disposed(by: rx.disposeBag)
        // 点击cell
        tableView.rx.modelSelected(MovieFavoritesCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = MovieDetailViewController.instanceFrom(storyboard: "Movie")
                vc.viewModel = MovieDetailViewControllerModel(movie: model.movie)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    // 编辑
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        xediting.toggle()
        
    }
    @IBAction func onSelectAll(_ sender: UIButton) {
        selectAll.accept(true)
    }
    @IBAction func onDelete(_ sender: UIButton) {
        
    }
    
}

extension Reactive where Base: NSLayoutConstraint {
    public var animationConstant: Binder<CGFloat> {
        return Binder(self.base) { constraint, constant in
            constraint.constant = constant
            UIView.animate(withDuration: 0.25) {
                (constraint.firstItem as? UILayoutGuide)?.owningView?.layoutIfNeeded()
            }
        }
    }
}


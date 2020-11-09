//
//  CircleListViewController.swift
//  TianXin
//
//  Created by pretty on 10/15/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

/// 所有圈子
class CircleListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: CircleListViewControllerModel?
    private let headerRefreshTrigger = PublishSubject<Void>()
    private let isHeaderLoading = BehaviorRelay(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
        tableView.configureDataSetView(options: [.empty: "暂无圈子"])
    }
    
    func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        self.navigationItem.title = viewModel.userId.isEmpty ? "全部圈子" : "TA加入的圈子"
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        
        let refresh = Observable.of(
            Observable.just(()).do(onNext: { SDSHUD.showloading() }),
            headerRefreshTrigger.asObservable()).merge()
        
        let input = CircleListViewControllerModel.Input(
            headerRefresh: refresh
        )
        let output = viewModel.transform(input: input)
        // 绑定cell
        output.items.drive(
            tableView.rx.items(cellIdentifier: "\(AttentionCell.self)", cellType: AttentionCell.self)
        ){
            index, viewModel, cell in
            cell.bind(viewModel)
            cell.attentionButton.attentionTitle = "已加入"
            cell.attentionButton.title = "加入"
        }.disposed(by: rx.disposeBag)
        output.items.map{$0.isEmpty}.drive(tableView.rx.isEmptyData).disposed(by: rx.disposeBag)
        // 点击cell
        tableView.rx.modelSelected(CircleListCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = CircleUserDetailVC(recommendId: "\(model.item.recommendId)")
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func makeUI() {
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation, self.view.rx.hudShown).disposed(by: rx.disposeBag)
    }

}

// MARK: - UITableViewDelegate
extension CircleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AttentionCell,
              let numbers = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section)
        else { return }
        if numbers == 0 { return }
        if numbers == 1 {
            cell.bgView?.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5)
            cell.separatorInset = .init(top: 0, left: tableView.center.x, bottom: 0, right: tableView.center.x)
            return
        }
        if indexPath.row == 0 {
            cell.bgView?.roundCorners([.topLeft, .topRight], radius: 5)
            cell.separatorInset = tableView.separatorInset
        } else if numbers - 1 == indexPath.row {
            cell.bgView?.roundCorners([.bottomLeft, .bottomRight], radius: 5)
            // 隐藏最后一个分割线
            cell.separatorInset = .init(top: 0, left: tableView.center.x, bottom: 0, right: tableView.center.x)
        } else {
            cell.bgView?.roundCorners(.allCorners, radius: 0)
            cell.separatorInset = tableView.separatorInset
        }
    }
}

// MARK: - view model
class CircleListViewControllerModel: NSObject, ViewModelType {
    let provider = HttpProvider<SquareApi>.default
    let headerLoading = ActivityIndicator()
    private let onAttention = PublishSubject<CircleItem>()
    
    // 是否是自己加入的圈子列表
    let userId: String?
    init(userId: String? = nil) {
        self.userId = userId
    }
    
    struct Input {
        let headerRefresh: Observable<Void>
    }
    struct Output {
        let items: Driver<[CircleListCellViewModel]>
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[CircleListCellViewModel]>(value: [])
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<[CircleItem]> in
            guard let self = self else { return Observable.just([]) }
            let api: SquareApi
            let keyPath: String
            if let userId = self.userId {
                api = SquareApi.checkJoinList(toId: userId)
                keyPath = "myJoinList"
            } else {
                api = SquareApi.squareList
                keyPath = "squareList"
            }
            return api.request(keyPath: keyPath, type: [CircleItem].self, provider: self.provider)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { [weak self] value in
            guard let weakself = self else { return }
            items.accept(value.map { item in
                let model = CircleListCellViewModel(item)
                model.onAttention
                    .bind(to: weakself.onAttention)
                    .disposed(by: weakself.rx.disposeBag)
                return model
            })
        },onError: { error in
        }).disposed(by: rx.disposeBag)
        // 点击关注按钮
        onAttention.asObservable()
            .flatMapLatest({[weak self](item) -> Observable<(CircleItem, Bool)> in
                guard let self = self else { return Observable.just((item, false)) }
                let api: SquareApi
                if item.isJoin {
                    // 点击退出圈子
                    api = SquareApi.delMyJoin(recommendId: "\(item.recommendId)")
                } else {
                    api = SquareApi.addMyJoin(recommendId: "\(item.recommendId)")
                }
                return api.request(provider: self.provider).map { (item, $0.code.string == "success") }
            })
            .subscribe(onNext: { [weak self]item, success in
                guard let self = self else { return }
                if success {
                    var value = items.value
                    if let idx = value.firstIndex(where: { $0.item.recommendId == item.recommendId }) {
                        var item = value[idx].item
                        if item.isJoin  {
                            item.isJoin = false
                        } else {
                            item.isJoin = true
                        }
                        let newModel = CircleListCellViewModel(item)
                        newModel.onAttention
                                .bind(to: self.onAttention)
                                .disposed(by: self.rx.disposeBag)
                        value[idx] = newModel
                    }
                    items.accept(value)
                }
            })
            .disposed(by: rx.disposeBag)
        
        return Output(
            items: items.asDriver()
        )
    }
}
// cell view model

struct CircleListCellViewModel {
    let imageUrl = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let userNum = BehaviorRelay<Int>(value: 0)
    let tzNum = BehaviorRelay<Int>(value: 0)
    let isJoined = BehaviorRelay<Bool>(value: false)
    
    let onAttention = PublishSubject<CircleItem>()
    
    let item: CircleItem
    init(_ item: CircleItem) {
        self.item = item
        imageUrl.accept(item.recommendPic)
        name.accept(item.recommendName)
        userNum.accept(item.recommendUserNum ?? 0)
        tzNum.accept(item.recommendTZNum ?? 0)
        isJoined.accept(item.isJoin)
    }
}

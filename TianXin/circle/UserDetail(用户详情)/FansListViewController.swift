//
//  FansListViewController.swift
//  TianXin
//
//  Created by pretty on 10/27/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class FansListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FansListViewControllerModel?
    private let headerRefreshTrigger = PublishSubject<Void>()
    private let footerRefreshTrigger = PublishSubject<Void>()
    private let isHeaderLoading = BehaviorRelay(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    private func makeUI() {
        tableView.configureDataSetView(options: [.empty: "暂无圈子"])
        tableView.backgroundColor = Configs.Theme.Color.backgroud
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: tableView.mj_header!.rx.isAnimation, self.view.rx.hudShown).disposed(by: rx.disposeBag)
    }
    
    private func bindViewModel() {
        guard let vm = viewModel else { return }
        self.navigationItem.title = vm.direction.title
        vm.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        vm.isLoding.asObservable().bind(to: self.view.rx.hudShown).disposed(by: rx.disposeBag)
        vm.errMsg.asObservable().bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        vm.noMoreData.asObservable().bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
        
        let headerRefresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = FansListViewControllerModel.Input(
            headerRefresh: headerRefresh,
            footerRefresh: footerRefreshTrigger
        )
        let output = vm.transform(input: input)
        // 绑定cell
        output.items.drive(tableView.rx.items(cellIdentifier: "\(AttentionCell.self)", cellType: AttentionCell.self)) {
            index, model, cell in
            cell.bind(model)
        }.disposed(by: rx.disposeBag)
        // 点击cell
        tableView.rx.modelSelected(FansListCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                // 跳转到用户主页
                let vc = UserDetailViewController.`init`(withUserId: model.json.userId.string)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: -
extension FansListViewController: UITableViewDelegate {
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

// MARK: - cell view model

struct FansListCellViewModel {
    let avatar = BehaviorRelay<String?>(value: nil)
    let name = BehaviorRelay<String?>(value: nil)
    let isAttention = BehaviorRelay<Bool>(value: false)
    let beCaredCount = BehaviorRelay<Int>(value: 0)
    let publishCount = BehaviorRelay<Int>(value: 0)
    
    let onAttention = PublishSubject<String>()
    
    let json: JSON
    init(_ json: JSON) {
        self.json = json
        avatar.accept(json.userLogo.string)
        name.accept(json.nickName.string.isEmpty ? json.userName.string : json.nickName.string)
        isAttention.accept(json.isAttention.int == 1)
        beCaredCount.accept(json.beCaredCount.int)
        publishCount.accept(json.publishCount.int)
    }
}

// MARK: - FansListViewControllerModel
class FansListViewControllerModel: NSObject, ViewModelType {
    enum Direction {
        case from // 被其他人关注
        case to // 关注其他人
    }
    let userId: String
    let direction: Direction
    init(_ userId: String, direction: Direction = .from) {
        self.userId = userId
        self.direction = direction
    }
    
    var page = 1
    var pageSize = 20
    
    let headerLoading = ActivityIndicator()
    let isLoding = ActivityIndicator()
    let errMsg = PublishSubject<String>()
    let noMoreData = PublishSubject<Bool>()
    lazy var provider = HttpProvider<SquareApi>.default
    
    let onAttention = PublishSubject<String>()
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }
    struct Output {
        let items: Driver<[FansListCellViewModel]>
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[FansListCellViewModel]>(value: [])
        // 下拉刷新
        input.headerRefresh.flatMapLatest({[weak self]() -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null) }
            self.page = 1
            let api = self.getApi()
            return api.request(provider: self.provider)
                .trackActivity(self.headerLoading)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
            } else {
                let keyPath = self.direction.keyPath
                let list = json[keyPath].array
                self.noMoreData.onNext(list.count < self.pageSize)
                items.accept(list.map{[weak self] ele in
                    let model = FansListCellViewModel(ele)
                    guard let self = self else { return model }
                    model.onAttention.bind(to: self.onAttention).disposed(by: self.rx.disposeBag)
                    return model
                })
            }
        }).disposed(by: rx.disposeBag)
        // 上拉加载更多
        input.footerRefresh.flatMapLatest({[weak self] () -> Observable<JSON> in
            guard let self = self else { return Observable.just(.null) }
            self.page += 1
            
            return self.getApi()
                .request(provider: self.provider)
        }).subscribe(onNext: { [weak self] json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
            } else {
                let keyPath = self.direction.keyPath
                let list = json[keyPath].array
                self.noMoreData.onNext(list.count < self.pageSize)
                items.accept(items.value + list.map{[weak self] ele in
                    let model = FansListCellViewModel(ele)
                    guard let self = self else { return model }
                    model.onAttention.bind(to: self.onAttention).disposed(by: self.rx.disposeBag)
                    return model
                })
            }
        }).disposed(by: rx.disposeBag)
        // 关注
        onAttention.flatMapLatest({[weak self] userId -> Observable<(String, JSON)> in
            guard let self = self,
                  let user = items.value.first(where: {$0.json.userId.string == userId })
            else { return .just((userId, .null)) }
            let api: SquareApi
            if user.isAttention.value {
                api = SquareApi.delMyAttention(toId: user.json.userId.string)
            } else {
                api = SquareApi.addAttention(toId: user.json.userId.string)
            }
            return api.request(provider: self.provider)
                .map({(userId, $0)})
                .trackActivity(self.isLoding)
        }).subscribe(onNext: { [weak self] userId, json in
            guard let self = self else { return }
            if json.code.string != "success" {
                self.errMsg.onNext(json.message.string)
            } else {
                if let index = items.value.firstIndex(where: {$0.json.userId.string == userId }) {
                    let user = items.value[index]
                    user.isAttention.toggle()
                    var value = items.value
                    value[index] = user
                    items.accept(value)
                }
            }
        }).disposed(by: rx.disposeBag)

        return Output(
            items: items.asDriver()
        )
    }
    
    private func getApi() -> SquareApi {
        let api: SquareApi
        switch direction {
        case .from:
            api = SquareApi.checkUserHomeFans(toId: userId, page: page, pageSize: pageSize)
        case .to:
            api = SquareApi.checkUserBeCared(toId: userId, page: page, pageSize: pageSize)
        }
        return api
    }
}

extension FansListViewControllerModel.Direction {
    var keyPath: String {
        switch self {
        case .from: return "fansList"
        case .to: return "myCareList"
        }
    }
    var title: String {
        switch self {
        case .from: return "关注TA的人"
        case .to: return "TA关注的人"
        }
    }
}

// MARK: -
extension AttentionCell {
    func bind(_ model: FansListCellViewModel) {
        model.avatar.map { try? $0?.asURL() }
            .asDriver(onErrorJustReturn: nil)
            .filterNil()
            .drive(avatarImageView.rx.imageURL)
            .disposed(by: rx.disposeBag)
        model.name.asDriver().drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        model.beCaredCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(peopleNumButton.rx.title()).disposed(by: rx.disposeBag)
        model.publishCount.map { "\($0)" }.asDriver(onErrorJustReturn: nil)
            .drive(issueNumButton.rx.title()).disposed(by: rx.disposeBag)
        model.isAttention.asDriver().drive(attentionButton.rx.isAttented).disposed(by: rx.disposeBag)
        
        attentionButton.rx.tap
            .map{model.json.userId.string}
            .bind(to: model.onAttention)
            .disposed(by: rx.disposeBag)
    }
}
/*
 "fansList": [
     {
       "toId": 456,
       "isAttention": 1,
       "createTime": "2020-10-26 18:57:45",
       "nickName": "11",
       "beCaredCount": 10,
       "userLogo": "https://tianxing-test1.s3.ap-east-1.amazonaws.com/b8b25cf11677497293d78dcf96c7f17f.jpeg",
       "userName": "winter1",
       "userId": 451,
       "publishCount": 49,
       "userBackgroundPic": null
     },
 ]
 */

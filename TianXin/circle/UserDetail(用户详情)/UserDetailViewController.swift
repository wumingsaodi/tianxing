//
//  UserDetailViewController.swift
//  TianXin
//
//  Created by pretty on 10/16/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

protocol UserDetailDataControllable {
    func relaodData()
}
protocol ScrollViewSimultaneouslable: class {
    var canScroll: Bool { set get }
    var isRefresh: Bool { set get }
}
extension UserDetailDataControllable {
    func relaodData() {}
}
class UserDetailViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var superScrollView: UIScrollView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    fileprivate var superCanScroll = true
    
    lazy private var headerViewController: UserDetailHeaderViewController? = {
        return children.first { $0 is UserDetailHeaderViewController } as? UserDetailHeaderViewController
    }()
    
    lazy private var baseHeight = ceil(Configs.Dimensions.screenWidth * (200.0 / 375.0)) + 40
    lazy private var barHeight = 44 + UIApplication.shared.statusBarFrame.height
    private var menuHeight = 66.5 as CGFloat
    
    private var menuItems: [UIButton] {
        return menuStackView.arrangedSubviews.filter { $0 is UIButton } as! [UIButton]
    }
    private let menuIndex = PublishSubject<Int>()
    private var currentIndex = 0
    private var dataChilds: [UserDetailDataControllable] = []
    
    // 外面传
    var viewModel: UserDetailViewControllerModel?
    var userId: String {
        return viewModel?.userId ?? ""
    }
    
    lazy fileprivate var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .init(x: 0, y: baseHeight + menuHeight + 10, width: Configs.Dimensions.screenWidth, height: KScreenH - menuHeight - barHeight))
        scrollView.backgroundColor = Configs.Theme.Color.backgroud
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        superScrollView.addSubview(scrollView)
        return scrollView
    }()
    
     static func `init`(withUserId userId: String) -> UserDetailViewController {
        let vc = UserDetailViewController.instanceFrom(storyboard: "UserDetail")
        vc.viewModel = .init(userId: userId)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.viewModel != nil, "请调用`init`方法来设置ViewModel")
        
        superScrollView.shouldSimultaneously = true
        superScrollView.delegate = self
        if #available(iOS 13.0, *) {
            superScrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            // Fallback on earlier versions
        }
        headerHeightConstraint.constant = baseHeight
        superScrollView.contentInsetAdjustmentBehavior = .never
        superScrollView.contentSize = .init(width: Configs.Dimensions.screenWidth, height: KScreenH + baseHeight - barHeight)
        
        contentScrollView.contentSize = .init(width: Configs.Dimensions.screenWidth * 4, height: contentScrollView.height)
        configMenuEvent()
        
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let vm = viewModel else { return }
        vm.errMsg.bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        
        let input = UserDetailViewControllerModel.Input(
            attentionEvent: headerViewController!.attentionEvent
        )
        
        let output = vm.transform(input: input)
        headerViewController?.bind(output.userInfo, isAttention: output.isAttention)
        output.userInfo.map{"发布\($0.publishCount.int)"}.drive(menuItems[0].rx.title()).disposed(by: rx.disposeBag)
        output.userInfo.map{"回复\($0.usReplyCount.int)"}.drive(menuItems[1].rx.title()).disposed(by: rx.disposeBag)
        output.userInfo.map{"收藏\($0.usColCount.int)"}.drive(menuItems[2].rx.title()).disposed(by: rx.disposeBag)
        output.userInfo.map{"足迹\($0.tripCount.int)"}.drive(menuItems[3].rx.title()).disposed(by: rx.disposeBag)
        
//        vm.isLoding.asObservable().bind(to: self.view.rx.hudShown).disposed(by: rx.disposeBag)
    }

    private func addDataChilds() {
        if menuItems.isEmpty { return }
        // 添加view
        // 发布
        let publishVc = UserPublishListViewController.instanceFrom(storyboard: "UserDetail")
        publishVc.viewModel = UserPublishListViewControllerModel(userId: self.userId, dataType: .发布)
        publishVc.superCanScroll.asObservable()
            .subscribe(onNext: { [weak self] canScroll in
                self?.superCanScroll = canScroll
            })
            .disposed(by: rx.disposeBag)
        addChild(publishVc)
        publishVc.view.frame = .init(x: 0, y: 0, width: contentScrollView.width, height: contentScrollView.contentSize.height)
        contentScrollView.addSubview(publishVc.view)
        dataChilds.append(publishVc)
        
        // 回复
        let replyVc = UserReplyListViewController.instanceFrom(storyboard: "UserDetail")
        replyVc.viewModel = UserReplyListViewControllerModel(userId: self.userId)
        addChild(replyVc)
        replyVc.superCanScroll.asObservable()
            .subscribe(onNext: { [weak self] canScroll in
                self?.superCanScroll = canScroll
            })
            .disposed(by: rx.disposeBag)
        replyVc.view.frame = .init(x: contentScrollView.width, y: 0, width: contentScrollView.width, height: contentScrollView.contentSize.height)
        contentScrollView.addSubview(replyVc.view)
        dataChilds.append(replyVc)
        // 收藏
        let favoriteVc = UserPublishListViewController.instanceFrom(storyboard: "UserDetail")
        addChild(favoriteVc)
        favoriteVc.viewModel = UserPublishListViewControllerModel(userId: self.userId, dataType: .收藏)
        favoriteVc.superCanScroll.asObservable()
            .subscribe(onNext: { [weak self] canScroll in
                self?.superCanScroll = canScroll
            })
            .disposed(by: rx.disposeBag)
        favoriteVc.view.frame = .init(x: contentScrollView.width * 2, y: 0, width: contentScrollView.width, height: contentScrollView.contentSize.height)
        contentScrollView.addSubview(favoriteVc.view)
        dataChilds.append(favoriteVc)
        // 足迹
        let trackVc = UserPublishListViewController.instanceFrom(storyboard: "UserDetail")
        addChild(trackVc)
        trackVc.viewModel = UserPublishListViewControllerModel(userId: self.userId, dataType: .足迹)
        trackVc.superCanScroll.asObservable()
            .subscribe(onNext: { [weak self] canScroll in
                self?.superCanScroll = canScroll
            })
            .disposed(by: rx.disposeBag)
        trackVc.view.frame = .init(x: contentScrollView.width * 3, y: 0, width: contentScrollView.width, height: contentScrollView.contentSize.height)
        contentScrollView.addSubview(trackVc.view)
        dataChilds.append(trackVc)
    }
    
    private func configMenuEvent() {
        addDataChilds()
        let btns = menuItems
        btns.forEach { btn in
            btn.rx.tapGesture().when(.ended).asObservable().map { _ in btn.tag }.bind(to: menuIndex).disposed(by: rx.disposeBag)
        }
        menuIndex.asObservable().bind(to: contentScrollView.rx.selectedIndex).disposed(by: rx.disposeBag)
        menuIndex.asObservable().subscribe(onNext: { [weak self] idx in
            guard let self = self else { return }
            let selectedBgColor = UIColor(red: 0.98, green: 0.84, blue: 0.67, alpha: 1)
            let bgColor = UIColor(white: 0.91, alpha: 1)
            let selectedTextColor = UIColor(red: 0.99, green: 0.58, blue: 0.06, alpha: 1)
            let textColor = UIColor(white: 0.60, alpha: 1)
            btns.forEach { btn in
                btn.backgroundColor = btn.tag == idx ? selectedBgColor : bgColor
                btn.setTitleColor(btn.tag == idx ? selectedTextColor : textColor, for: .normal)
            }
            self.currentIndex = idx
            self.dataChilds[idx].relaodData()
        }).disposed(by: rx.disposeBag)
        
        menuIndex.onNext(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
}


extension UserDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // adjust header
        headerViewController?.toper.onNext(self.superScrollView.contentOffset.y)
        
        let maxOffsetY = self.baseHeight - self.barHeight
        let childScroll = self.dataChilds[self.currentIndex] as? ScrollViewSimultaneouslable
        if superScrollView.contentOffset.y <= 0 {
            superScrollView.contentOffset.y = 0
            childScroll?.isRefresh = true
            return
        }
        childScroll?.isRefresh = false
        if !self.superCanScroll {
            self.superScrollView.contentOffset.y = maxOffsetY
            childScroll?.canScroll = true
        } else {
            if maxOffsetY <= self.superScrollView.contentOffset.y {
                self.superScrollView.contentOffset.y = maxOffsetY
                self.superCanScroll = false
                childScroll?.canScroll = true
            }
            
        }
    }
}

//
//  HomeMenuPresentViewController.swift
//  TianXin
//
//  Created by pretty on 10/27/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeMenuPresentViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let column = 4
    private var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    private let items = BehaviorRelay<[HomeMenuCellModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        
        collectionView.rx.modelSelected(HomeMenuCellModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                self?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .HomeMenuOnTap, object: model.item)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        let spacingWidth = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(column - 1)
        let itemWidth = (Configs.Dimensions.screenWidth - spacingWidth) / CGFloat(column)
        flowLayout.itemSize = .init(width: itemWidth, height: itemWidth)
        
        self.view.rx.tapGesture()
            .asObservable()
            .do(onNext: { [weak self] tap in
                tap.delegate = self
            })
            .subscribe(onNext: { [weak self] tap in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bindViewModel(_ items: [typeItmeModel]) {
        self.items.accept(items.map{HomeMenuCellModel($0)})
        self.items.asDriver()
            .drive(collectionView.rx.items(cellIdentifier: "\(HomeMenuCell.self)", cellType: HomeMenuCell.self)){
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
    }
}

extension HomeMenuPresentViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.superview is HomeMenuCell {
            return false
        }
        return true
    }
}

extension UIViewController {
    @discardableResult
    func presentHomeMenu() -> HomeMenuPresentViewController{
        let vc = HomeMenuPresentViewController.instanceFrom(storyboard: "Home")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.showDetailViewController(vc, sender: self)
        return vc
    }
}

extension UIView {
    @discardableResult
    func presentHomeMenu() -> HomeMenuPresentViewController {
        let vc = HomeMenuPresentViewController.instanceFrom(storyboard: "Home")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.viewController()?.showDetailViewController(vc, sender: self.viewController())
        return vc
    }
}

// MARK: - cell
class HomeMenuCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate func bind(_ model: HomeMenuCellModel) {
        model.cover.map{try? $0?.asURL()}.asDriver(onErrorJustReturn: nil).filterNil()
            .drive(imageView.rx.imageURL).disposed(by: rx.disposeBag)
        model.title.asDriver().drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
    }
}

// MARK: - CELL VIEW MODEL
struct HomeMenuCellModel {
    let cover = BehaviorRelay<String?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    
    let item: typeItmeModel
    init(_ item: typeItmeModel) {
        self.item = item
        cover.accept(item.picUrl)
        title.accept(item.type)
    }
}


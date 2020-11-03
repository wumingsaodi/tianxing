//
//  UserPublishListCell.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class UserPublishListCell: RxTableViewCell<UserPublishIssueItemViewModel> {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderIcon: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeNumButton: UIButton!
    @IBOutlet weak var commentNumButton: UIButton!
    @IBOutlet weak var imageCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleCollectionView: UICollectionView!
    @IBOutlet weak var circleListHeightConstraint: NSLayoutConstraint!
    
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        return imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }()
    
    lazy var circleListFlowLayout: UICollectionViewFlowLayout = {
        return circleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }()
    
    var imageUrls: [String] = []
    var videoUrl: String?
    var circleWidths: [String: CGFloat] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollectionView.registerNib(type: VideoCollectionViewCell.self)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.isScrollEnabled = false
        imageCollectionViewHeightConstraint.constant = 0
    }
    
    override func bind(_ model: UserPublishIssueItemViewModel) {
        super.bind(model)
        
        model.avatarUrl.map({try? $0?.asURL()}).asDriver(onErrorJustReturn: nil)
            .filterNil().drive(avatarImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.name.asDriver().drive(nameLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
        model.likeNum.map({"\($0)"}).asDriver(onErrorJustReturn: nil)
            .drive(likeNumButton.rx.title()).disposed(by: cellDisposeBag)
        model.replyNum.map({"\($0)"}).asDriver(onErrorJustReturn: nil)
            .drive(commentNumButton.rx.title()).disposed(by: cellDisposeBag)
        model.isLiked.asDriver().drive(likeNumButton.rx.isSelected).disposed(by: cellDisposeBag)
        
        model.imageUrls.asDriver().drive(onNext: { [weak self] imageUrls in
            guard let self = self else { return }
            if !imageUrls.isEmpty {
                let spacing = self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right + self.flowLayout.minimumInteritemSpacing * 2 + 48
                let itemWidth = (Configs.Dimensions.screenWidth - spacing) / 3
                self.flowLayout.itemSize = .init(width: itemWidth, height: itemWidth)
                self.imageCollectionViewHeightConstraint.constant = ceil(CGFloat((imageUrls.count + 2) / 3)) * 110
                
                self.imageUrls = imageUrls
                self.imageCollectionView.reloadData()
            }
        }).disposed(by: cellDisposeBag)
        // video url
        model.videoUrl.asDriver().drive(onNext: {[weak self] videoUrl in
            if !videoUrl.isEmpty {
                //  16:9
                let itemWidth = Configs.Dimensions.screenWidth - 48
                let itemHeight = ceil(itemWidth * 9 / 16)
                self?.imageCollectionViewHeightConstraint.constant = itemHeight
                self?.flowLayout.itemSize = .init(width: itemWidth, height: itemHeight)
                self?.imageCollectionViewHeightConstraint.constant = itemHeight
                
                self?.videoUrl = videoUrl
                self?.imageCollectionView.reloadData()
            }
        }).disposed(by: cellDisposeBag)
//        model.imageUrls.map({ceil(CGFloat(($0.count + 2) / 3)) * 110}).asDriver(onErrorJustReturn: 0)
//            .drive(imageCollectionViewHeightConstraint.rx.constant).disposed(by: rx.disposeBag)
        
        model.circleNameWidths.asDriver().drive(onNext: {[weak self] widths in
            self?.circleWidths = widths
            self?.circleCollectionView.reloadData()
        }).disposed(by: cellDisposeBag)
        
        likeNumButton.rx.tap
            .map { [weak self] _ in ("\(model.item.issueId)", !(self?.likeNumButton.isSelected ?? false))}
            .bind(to: model.onLike)
            .disposed(by: cellDisposeBag)
        commentNumButton.rx.tap
            .map { _ in "\(model.item.issueId)"}
            .bind(to: model.onComment)
            .disposed(by: cellDisposeBag)
        
        // 圈子列表
        circleCollectionView.rx.setDelegate(self).disposed(by: cellDisposeBag)
        model.circles.asDriver().drive(circleCollectionView.rx.items(cellIdentifier: "\(CircleNameListCell.self)", cellType: CircleNameListCell.self)) {
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: cellDisposeBag)
        model.circles.map{$0.isEmpty ? 0 : 30}.asDriver(onErrorJustReturn: 0)
            .drive(circleListHeightConstraint.rx.constant)
            .disposed(by: cellDisposeBag)
        
        circleCollectionView.rx.modelSelected(CircleItem.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = CircleUserDetailVC(recommendId: "\(model.recommendId)")
                self?.viewController()?.show(vc, sender: self)
            })
            .disposed(by: cellDisposeBag)
        
        // Assertion failed: This is a feature to warn you that there is already a delegate (or data source) set somewhere previously. The action you are trying to perform will clear that delegate (data source) and that means that some of your features that depend on that delegate (data source) being set will likely stop working.
//        model.imageUrls.asDriver()
//            .drive(imageCollectionView.rx.items(cellIdentifier: "\(ImageCollectionViewCell.self)", cellType: ImageCollectionViewCell.self)){
//                index, viewModel, cell in
//                cell.bind(viewModel)
//            }.disposed(by: cellDisposeBag)
    }
}

extension UserPublishListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !videoUrl.isEmpty { return 1 }
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !imageUrls.isEmpty {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as ImageCollectionViewCell
            cell.bind(imageUrls[indexPath.row])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(for: indexPath) as VideoCollectionViewCell
        cell.bind(videoUrl ?? "")
        return cell
    }
}

extension UserPublishListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == circleCollectionView {
            return
        }
        var photos: [Photo] = []
        for row in 0 ..< imageUrls.count {
            photos.append(.init(photoUrl: try? imageUrls[row].asURL(), image: (collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ImageCollectionViewCell)?.imageView.image))
        }
        if photos.isEmpty {
            return
        }
        let vc = PhotoBrowser(photos: photos, initialPageIndex: indexPath.row, fromView: collectionView.cellForItem(at: indexPath))
        self.viewController()?.present(vc, animated: true, completion: nil)
    }
}

extension UserPublishListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView {
            return flowLayout.itemSize
        }
        let name = model?.circles.value[indexPath.row].recommendName ?? ""
        return .init(width: circleWidths[name] ?? 0 + 20, height: 20)
    }
}

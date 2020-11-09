//
//  IssueDetailHeaderViewController.swift
//  TianXin
//
//  Created by pretty on 10/19/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssueDetailHeaderViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var circleCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var circleCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attentionButton: AttentionButton!
    @IBOutlet weak var playerView: SDSAVView!
    
    var flowLayout: UICollectionViewFlowLayout {
        return imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    var circleFlowLayout: UICollectionViewFlowLayout {
        return circleCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var userId: String = ""
    
    var imageUrls: [String] = []
    
    let onLike = PublishSubject<Void>()
    let onAttention = PublishSubject<Void>()
    let onFavorite = PublishSubject<Void>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.isCanBeiginPlay = false
        
        avatarImageView.isUserInteractionEnabled = true
        setupLayout()
        
        avatarImageView.rx.tapGesture()
            .when(.ended)
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if LocalUserInfo.share.userId?.toString() == self.userId {
                    return
                }
                let vc = UserDetailViewController.`init`(withUserId: self.userId)
                self.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        
        likeButton.rx.tap
            .bind(to: onLike)
            .disposed(by: rx.disposeBag)
        
        attentionButton.rx.tap
            .asObservable()
            .bind(to: onAttention)
            .disposed(by: rx.disposeBag)
        favoriteButton.rx.tap
            .asObservable()
            .bind(to: onFavorite)
            .disposed(by: rx.disposeBag)
    }

    func bind(_ issue: Driver<IssueDetail>) {
        issue.map { $0.userId == LocalUserInfo.share.userId }.asDriver()
            .drive(attentionButton.rx.isHidden)
            .disposed(by: rx.disposeBag)
        issue.map { try? $0.userLogo?.asURL() }
            .filterNil()
            .drive(avatarImageView.rx.imageURL)
            .disposed(by: rx.disposeBag)
        issue.map { $0.nickName ?? $0.userName }.drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        issue.map { $0.issueContent }.drive(contentLabel.rx.text).disposed(by: rx.disposeBag)
        issue.map { $0.createTime }.drive(timeLabel.rx.text).disposed(by: rx.disposeBag)
        issue.map { "\($0.issueLikeCount ?? 0)" }.drive(likeButton.rx.title()).disposed(by: rx.disposeBag)
        issue.map { "\($0.issuePVCount ?? 0)" }.drive(viewButton.rx.title()).disposed(by: rx.disposeBag)
        issue.map { "\($0.collectCount ?? 0)" }.drive(favoriteButton.rx.title()).disposed(by: rx.disposeBag)
        issue.map { $0.isAttention }.drive(attentionButton.rx.isAttented).disposed(by: rx.disposeBag)
        // 圈子列表
        issue.map { $0.joinRecommendList}
            .filterNil()
            .drive(circleCollectionView.rx.items(cellIdentifier: "\(CircleNameListCell.self)", cellType: CircleNameListCell.self)){
                index, viewModel, cell in
                cell.bind(viewModel)
            }
            .disposed(by: rx.disposeBag)
        issue.map { CGFloat($0.joinRecommendList.isEmpty ? 0 : 25) }
            .drive(circleCollectionViewHeightConstraint.rx.constant).disposed(by: rx.disposeBag)
        // 点击 圈子列表cell
        circleCollectionView.rx.modelSelected(CircleItem.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = CircleUserDetailVC(recommendId: "\(model.recommendId)")
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        // images
        issue.map { $0.issuePic }
            .filterNil()
            .drive(imageCollectionView.rx.items(cellIdentifier: "\(ImageCollectionViewCell.self)", cellType: ImageCollectionViewCell.self)){
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
        issue.map{$0.issuePic}
            .filterNil()
            .drive(onNext: { [weak self] imgUrls in
                self?.imageUrls = imgUrls
            })
            .disposed(by: rx.disposeBag)
        // video
        issue.map { try? $0.issueVideo?.asURL() }
            .filterNil()
            .drive(playerView.rx.videoURL)
            .disposed(by: rx.disposeBag)
        issue.map { $0.issueVideo.isEmpty }
            .drive(playerView.rx.isHidden).disposed(by: rx.disposeBag)
        issue.map {[weak self] in
            $0.issueVideo.isEmpty ?
                self?.calculateHeight(itemCount: $0.issuePic?.count ?? 0) ?? 0 :
                (Configs.Dimensions.screenWidth - 48) * 9 / 16
        }.drive(imageCollectionViewHeightConstraint.rx.constant)
        .disposed(by: rx.disposeBag)
        
        
        issue.map {$0.userId}.drive(onNext: { [weak self] userId in
            self?.userId = "\(userId)"
        }).disposed(by: rx.disposeBag)
        
        // 点击图片
        imageCollectionView.rx.itemSelected
            .asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                var photos: [Photo] = []
                for row in 0 ..< self.imageUrls.count {
                    photos.append(.init(photoUrl: try? self.imageUrls[row].asURL(), image: (self.imageCollectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ImageCollectionViewCell)?.imageView.image))
                }
                let vc = PhotoBrowser(photos: photos,
                                      initialPageIndex: indexPath.row,
                                      fromView: self.imageCollectionView.cellForItem(at: indexPath))
                self.present(vc, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bind(_ isLike: Driver<Bool>, _ isFavorited: Driver<Bool>) {
        isLike.drive(likeButton.rx.isSelected).disposed(by: rx.disposeBag)
        isFavorited.drive(favoriteButton.rx.isSelected).disposed(by: rx.disposeBag)
    }
    
    
    var itemHeight: CGFloat {
        return flowLayout.itemSize.height + flowLayout.minimumLineSpacing
    }
    func calculateHeight(itemCount: Int) -> CGFloat {
        return CGFloat((itemCount + 2) / 3) * itemHeight
    }
    
    private func setupLayout() {
        let itemWidth = (Configs.Dimensions.screenWidth - 48 - flowLayout.minimumInteritemSpacing * 2) / 3
        flowLayout.itemSize = .init(width: itemWidth, height: itemWidth)
        circleFlowLayout.estimatedItemSize = .init(width: 1, height: 1)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 13, *) {
            
        } else {
            circleCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
}


class CircleNameListCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    func bind(_ model: CircleItem) {
        label.text = model.recommendName
    }
}

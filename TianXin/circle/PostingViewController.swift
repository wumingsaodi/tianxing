//
//  PostingViewController.swift
//  TianXin
//
//  Created by pretty on 10/14/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZLPhotoBrowser
import Photos
import PKHUD

class PostingViewController: UIViewController {
    lazy var publishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("发布", for: .normal)
        button.size = .init(width: 64, height: 26)
        button.cornerRadius = 13
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .init(white: 0.8, alpha: 1)
        return button
    }()
    lazy var publishButtonBackgroundView: UIView = {
        let v = UIView(frame: .init(x: 0, y: 0, width: 64, height: 26))
        v.addSubview(publishButton)
        return v
    }()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var wordsLimitLabel: UILabel!
    @IBOutlet weak var photoSelectionCollectionView: UICollectionView!
    @IBOutlet weak var avatarSelectionCollectionView: UICollectionView!
    @IBOutlet weak var photoSelectionHeightConstraint: NSLayoutConstraint!
    // 选择发布到广场
    @IBOutlet weak var checkOnSquareButton: UIButton!
    @IBOutlet weak var circleListHeightConstraint: NSLayoutConstraint!
    
    private var photoSelectionFlowLayout: UICollectionViewFlowLayout {
        return photoSelectionCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var viewModel: PostingViewControllerModel!
    
    private let selectedPhotos = BehaviorRelay<[PhotoSelectionCellViewModel]>(value: [PhotoSelectionCellViewModel(image: R.image.add(), type: .add)])
    private let selectedVideo = PublishSubject<PHAsset>()
    private var selectedAssets: [PHAsset] = []
    private let deletePhoto = PublishSubject<Int>()
    private let postEvent = PublishSubject<PostingViewControllerModel.Issue>()
    private let onSquare = BehaviorRelay<Bool>(value: true)
    
    static func `init`(viewModel: PostingViewControllerModel) -> PostingViewController {
        let vc = PostingViewController.instanceFrom(storyboard: "Circle")
        vc.viewModel = viewModel
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.publishButtonBackgroundView)
        makeUI()
        bindViewModel()
        bindPhotoAction()
        
    }
    private func bindViewModel() {
        // 关联UI
        textView.rx.text.changed
            .asObservable()
            .distinctUntilChanged()
            .map { !($0?.isEmpty ?? true) }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        textView.rx.text.asObservable()
            .subscribe(onNext: { [weak self]text in
                self?.publishButton.isEnabled = !text.isEmpty
                self?.publishButton.backgroundColor = text.isEmpty ? .init(white: 0.8, alpha: 1) : Configs.Theme.Color.primary
            })
            .disposed(by: rx.disposeBag)
        checkOnSquareButton.rx.tap
            .map {[weak self] in return self?.checkOnSquareButton.isSelected }
            .filterNil()
            .map({!$0})
            .asObservable()
            .bind(to: onSquare)
            .disposed(by: rx.disposeBag)
        onSquare.asObservable().bind(to: checkOnSquareButton.rx.isSelected).disposed(by: rx.disposeBag)
        textView.rx.text
            .orEmpty
            .map{$0.count}
            .map{"\($0)/2000"}
            .asDriverOnErrorJustComplete()
            .drive(wordsLimitLabel.rx.text)
            .disposed(by: rx.disposeBag)
        textView.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text.count > 2000 && self.textView.markedTextRange == nil {
                    self.textView.text = String(text[text.startIndex ..< text.index(text.startIndex, offsetBy: 2000)])
                }
            })
            .disposed(by: rx.disposeBag)
        
        checkOnSquareButton.superview?.isHidden = viewModel.fromType == .广场
        // viewmodel
        let input = PostingViewControllerModel.Input(
            postEvent: postEvent.asObservable()
        )
        let output = viewModel.transform(input: input)
        // 显示我的加入圈子列表
        output.circleItems.drive(avatarSelectionCollectionView.rx.items(cellIdentifier: "\(AvatarSelectionCell.self)", cellType: AvatarSelectionCell.self)) {
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: rx.disposeBag)
        output.circleListHidden.map{$0 ? 0 : 88}.drive(circleListHeightConstraint.rx.constant).disposed(by: rx.disposeBag)
        output.circleListHidden.drive(avatarSelectionCollectionView.superview!.rx.isHidden).disposed(by: rx.disposeBag)
        // 点击圈子cell
        avatarSelectionCollectionView.rx.modelSelected(AvatarSelectionCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { model in
                model.isSelected.toggle()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.isLoading.asObservable().bind(to: self.view.rx.hudShown).disposed(by: rx.disposeBag)
        viewModel.error.map { $0.localizedDescription }.asObservable().bind(to: self.view.rx.errorMsg).disposed(by: rx.disposeBag)
        viewModel.errMsg.bind(to: view.rx.errorMsg).disposed(by: rx.disposeBag)
        viewModel.success.asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        // 发布内容
        publishButton.rx.tap.asObservable()
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                let pattern = "[^0-9^a-zA-Z]{0,}$"
                let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
                if !regex.evaluate(with: self.textView.text) {
                    HUD.flash(.label("内容不允许出现数字、英文字母"), delay: 1.5)
                    return false
                }
                return true
            })
            .map { [weak self]() -> PostingViewControllerModel.Issue? in
            guard let self = self else { return nil }
            return PostingViewControllerModel.Issue(
                remark: self.textView.text,
                images: self.selectedPhotos.value.filter({$0.type == .image}).map { $0.image.value }.compactMap({$0}),
                isSquare: self.onSquare.value
            )
        }
        .filterNil()
        .bind(to: postEvent)
        .disposed(by: rx.disposeBag)
    }
    
    private func bindPhotoAction() {
        // 绑定photo selection collectionview
        selectedPhotos
            .asDriver()
            .drive(photoSelectionCollectionView.rx.items(cellIdentifier: "\(PhotoSelectionCell.self)", cellType: PhotoSelectionCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }
            .disposed(by: rx.disposeBag)
        // 绑定 photo selection height
        let lineHeight = self.photoSelectionFlowLayout.itemSize.width + self.photoSelectionFlowLayout.minimumLineSpacing
        selectedPhotos.map {
            CGFloat(($0.count + 2) / 3) * lineHeight
        }
        .bind(to: photoSelectionHeightConstraint.rx.constant)
        .disposed(by: rx.disposeBag)
        // 点击图片
        photoSelectionCollectionView.rx.modelSelected(PhotoSelectionCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                switch model.type {
                case .add:
                    // 隐藏键盘
                    self?.textView.resignFirstResponder()
                    self?.openPhotoBrowser()
                case .image: break
                case .video: break
                }
            })
            .disposed(by: rx.disposeBag)
        // 删除图片
        deletePhoto.asObservable().subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            if self.selectedAssets.count > index {
                self.selectedAssets.remove(at: index)
            }
            var value = self.selectedPhotos.value
            if value.count > index {
                value.remove(at: index)
                if case .add = value.last?.type {
                    
                } else {
                    value.append(PhotoSelectionCellViewModel(image: R.image.add(), type: .add))
                }
                self.selectedPhotos.accept(value)
            }
        }).disposed(by: rx.disposeBag)
        
    }
    // 打开相册
    private func openPhotoBrowser() {
        let ps = ZLPhotoPreviewSheet(selectedAssets: selectedAssets)
        ps.selectImageBlock = {[weak self](images, assets, isOriginal) in
            guard let self = self else { return }
            self.selectedAssets = assets
            // 判断是否为视频
            if assets.count == 1 && assets[0].mediaType == .video {
                self.selectedVideo.onNext(assets[0])
                let cellModel = PhotoSelectionCellViewModel(image: images[0], type: .video)
                cellModel.deleted
                    .asObservable()
                    .bind(to: self.deletePhoto)
                    .disposed(by: self.rx.disposeBag)
                self.selectedPhotos.accept([cellModel])
                return
            }
            // 全部为图片
            var imageModes: [PhotoSelectionCellViewModel] = []
            for image in images {
                let cellModel = PhotoSelectionCellViewModel(image: image, type: .image)
                cellModel.deleted
                    .asObservable()
                    .bind(to: self.deletePhoto)
                    .disposed(by: self.rx.disposeBag)
                imageModes.append(cellModel)
            }
            if images.count < 9 {
                imageModes.append(PhotoSelectionCellViewModel(image: R.image.add(), type: .add))
            }
            self.selectedPhotos.accept(imageModes)
        }
        ps.showPreview(animate: true, sender: self)
    }
}


extension PostingViewController {
    func makeUI() {
        self.navigationItem.title = "发帖"
        hidesBottomBarWhenPushed = true
        self.view.backgroundColor = .white
        // 最多选择9张照片或者仅选择一个视频
        ZLPhotoConfiguration.default().maxSelectCount = 9
        ZLPhotoConfiguration.default().allowSelectImage = true
        ZLPhotoConfiguration.default().allowSelectVideo = true
        ZLPhotoConfiguration.default().allowMixSelect = false
        //
        let spacing = photoSelectionFlowLayout.sectionInset.left + photoSelectionFlowLayout.sectionInset.right + photoSelectionFlowLayout.minimumInteritemSpacing * 2 + 32
        let itemWidth = (Configs.Dimensions.screenWidth - spacing) / 3
        photoSelectionFlowLayout.itemSize = .init(width: itemWidth, height: itemWidth)
        
    }
}

extension PostingViewController {
    enum PhotoSelectionType {
        case add
        case image
        case video
    }
    struct PhotoSelectionCellViewModel {
        let type: PhotoSelectionType
        let image = BehaviorRelay<UIImage?>(value: nil)
        
        let deleted = PublishSubject<Int>()
        
        init(image: UIImage? = nil, type: PhotoSelectionType) {
            self.type = type
            self.image.accept(image)
        }
    }
}


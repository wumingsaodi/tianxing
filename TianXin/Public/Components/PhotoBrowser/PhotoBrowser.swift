//
//  PhotoBrowser.swift
//  TianXin
//
//  Created by pretty on 10/27/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Photos
import PKHUD

protocol PhotoSource {
    var image: UIImage? { get }
    var photoUrl: URL? { get }
}
extension PhotoSource {
    var image: UIImage? { return nil }
    var photoUrl: URL? { return nil }
}
extension URL: PhotoSource {}
extension String: PhotoSource {
    var photoUrl: URL? {
        return try? self.asURL()
    }
}
extension UIImage: PhotoSource {}

struct Photo {
    var photoUrl: URL?
    var image: UIImage?
}
extension Photo: PhotoSource {}

class PhotoBrowser: UIViewController {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.minimumZoomScale = 0.25
        collectionView.maximumZoomScale = 4
        self.view.addSubview(collectionView)
        return collectionView
    }()
    lazy var downloadButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.download(), for: .normal)
        btn.size = .init(width: 50, height: 50)
        btn.backgroundColor = UIColor(hex: 0x191D24)
        btn.cornerRadius = 25
        btn.contentMode = .center
        self.view.addSubview(btn)
        return btn
    }()
    lazy var dismissButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(hex: 0x191D24)
        btn.size = .init(width: 22, height: 22)
        btn.cornerRadius = 11
        btn.setTitle("X", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        self.view.addSubview(btn)
        return btn
    }()
    
    lazy var numberOfPhotoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.backgroundColor = UIColor(hex: 0x191D24)
        label.cornerRadius = 12
        label.textAlignment = .center
        self.view.addSubview(label)
        return label
    }()
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    fileprivate let serialQueue = DispatchQueue(label: "Decode queue")
    fileprivate var cacheImages = [UIImage?]()
    
    var currentImageView: UIImageView? {
        return (collectionView.cellForItem(at: .init(row: currentIndex, section: 0)) as? PhotoPageCell)?.imageView
    }
    
    // MARK: - properties
    var photos: [PhotoSource] = []
    var currentIndex: Int = 0 {
        didSet {
            numberOfPhotoLabel.text = "\(currentIndex + 1)/\(photos.count)"
        }
    }
    fileprivate lazy var animator = PhotoAnimator()
    
    // MARK: - init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init(photos: [PhotoSource]) {
        self.init(photos: photos, initialPageIndex: 0)
    }
    
    convenience init(photos: [PhotoSource], initialPageIndex: Int) {
        self.init(photos: photos, initialPageIndex: initialPageIndex, fromView: nil)
    }
    convenience init(photos: [PhotoSource], initialPageIndex: Int, fromView: UIView?) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.cacheImages = .init(repeating: nil, count: photos.count)
        self.currentIndex = initialPageIndex
        
        if let imgView = fromView as? UIImageView {
            animator.originImage = imgView.image
            animator.fromView = fromView
        } else if let imgView = fromView?.subviews.search(where: {$0 is UIImageView }) as? UIImageView {
            animator.originImage = imgView.image
            animator.fromView = imgView
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0x20242F)
        makeUI()
        configureCollectionView()
        configureEvents()
        
        numberOfPhotoLabel.text = "\(currentIndex + 1)/\(photos.count)"
        numberOfPhotoLabel.sizeToFit()
        numberOfPhotoLabel.snp.makeConstraints { maker in
            maker.right.equalTo(dismissButton.snp_leftMargin).offset(-25)
            maker.centerY.equalTo(dismissButton.snp.centerY)
            maker.width.equalTo(numberOfPhotoLabel.width + 20)
            maker.height.equalTo(24)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefetchFirstImage()
        collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        animator.willPresent(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 清理内存
        ImageCache.default.clearMemoryCache()
    }
    
    // MARK: - setup
    
    func configureEvents() {
        dismissButton.addTarget(self, action: #selector(onDismiss(sender:)), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(onDownload(sender:)), for: .touchUpInside)
    }
    
    func configureCollectionView() {
        flowLayout.itemSize = self.view.bounds.size
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(PhotoPageCell.classForCoder(), forCellWithReuseIdentifier: "\(PhotoPageCell.self)")
    }
    
    func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 20
        let costMemory = (costLimit > Int.max) ? Int.max : Int(costLimit)
        ImageCache.default.memoryStorage.config.totalCostLimit = costMemory
    }
    private func makeUI() {
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        downloadButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-25)
            maker.size.equalTo(CGSize(width: 50, height: 50))
        }
        dismissButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(50)
            maker.right.equalToSuperview().offset(-10)
            maker.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        
    }
    // MARK: - events
    @objc private func onDismiss(sender: UIButton) {
        animator.willDismiss(self)
    }
    
    @objc private func onDownload(sender: UIButton) {
        switch photos[currentIndex] {
        case let image as UIImage:
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        HUD.flash(.label("保存成功"))
                    } else {
                        HUD.flash(.label("保存失败"))
                    }
                }
            }
        case let string as String:
            if let url = URL(string: string) {
                downloadImage(url: url)
            }
        case let url as URL:
            downloadImage(url: url)
        default:
            if let url = photos[currentIndex].photoUrl {
                downloadImage(url: url)
            }
        }
    }
    
    private func downloadImage(url: URL) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case let .success(imgResult):
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: imgResult.image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            HUD.flash(.label("保存成功"), onView: self.view)
                        } else {
                            HUD.flash(.label("保存失败"), onView: self.view)
                        }
                    }
                }
            case .failure:
                HUD.flash(.label("保存失败"))
            }
        }
    }
    private func downloadImage(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
        [kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
     
        guard let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return UIImage()
        }
        return UIImage(cgImage: downsampledImage)
    }
    
    private func update(at indexPath: IndexPath, with image: UIImage?) {
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoPageCell
        cell?.imageView.image = image
    }
    
    private func prefetchFirstImage() {
        let size = collectionView.size
        let scale = collectionView.traitCollection.displayScale
        
        let photo = photos[currentIndex]
        
        if let url = photo.photoUrl {
            serialQueue.async {
                let downloadImage = self.downloadImage(imageAt: url, to: size, scale: scale)
                DispatchQueue.main.async {
                    self.cacheImages[self.currentIndex] = downloadImage
                    self.update(at: IndexPath(row: self.currentIndex, section: 0), with: downloadImage)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoBrowser: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as PhotoPageCell
        cell.layoutIfNeeded()
        let photo = photos[indexPath.row]
        let image = cacheImages[indexPath.row] ?? photo.image
        cell.imageView.image = image
        if let url = photo.photoUrl, image == nil {
            // 使用Kingfisher缓存
            cell.imageView.kf.setImage(with: url)
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotoBrowser: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photo = photos[indexPath.row]
            if cacheImages[indexPath.row] != nil {
                return
            }
            if let url = photo.photoUrl {
                let size = collectionView.size
                let scale = collectionView.traitCollection.displayScale
                serialQueue.async {
                    let downloadImage = self.downloadImage(imageAt: url, to: size, scale: scale)
                    DispatchQueue.main.async {
                        self.cacheImages[indexPath.row] = downloadImage
                        self.update(at: indexPath, with: downloadImage)
                    }
                }
            }
        }
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoBrowser: UICollectionViewDelegateFlowLayout {
    
}
// MARK: - UICollectionViewDelegate
extension PhotoBrowser: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoPageCell)?.reset()
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        (cell as? PhotoPageCell)?.imageView.kf.cancelDownloadTask()
        
    }
}

// MARK: -
extension PhotoBrowser: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndex = Int(scrollView.contentOffset.x / scrollView.width)
    }
}

// MARK: - photo cell
class PhotoPageCell: UICollectionViewCell {
    // 用于放大缩小
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.contentSize = scrollView.size
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        self.contentView.addSubview(scrollView)
        return scrollView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .init(x: 10, y: 0, width: scrollView.width - 20, height: scrollView.height))
        imageView.contentMode = .scaleAspectFit
        self.scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        return imageView
    }()
    
    func reset() {
        scrollView.setZoomScale(1, animated: false)
    }
    
    @objc private func onDoubleTap(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension PhotoPageCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.width > scrollView.contentSize.width ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = scrollView.height > scrollView.contentSize.height ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0
        let centerX = scrollView.contentSize.width * 0.5 + offsetX
        let centerY = scrollView.contentSize.height * 0.5 + offsetY
        imageView.center = .init(x: centerX, y: centerY)
    }
}

extension Array where Element: UIView {
    func search(`where`: (UIView) -> Bool) -> UIView? {
        if isEmpty { return nil }
        for v in self {
            if `where`(v) {
                return v
            }
            return v.subviews.search(where: `where`)
        }
        return nil
    }
}

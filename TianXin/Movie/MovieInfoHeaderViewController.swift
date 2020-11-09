//
//  MovieInfoHeaderViewController.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieInfoHeaderViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    let movie = BehaviorRelay<TopicMovie?>(value: nil)
//    let items = BehaviorRelay<[String]>(value: [])
    let height = BehaviorRelay<CGFloat>(value: 0)
    
    let likeMovie = PublishSubject<Void>()
    let favoriteMovie = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movie.map { $0?.title }.asDriver(onErrorJustReturn: nil)
            .drive(titleLabel.rx.text).disposed(by: rx.disposeBag)
        movie.map { "\($0?.createTime ?? "")/\($0?.visitCount?.unitCountString ?? "")次播放" }
            .asDriver(onErrorJustReturn: nil).drive(subtitleLabel.rx.text).disposed(by: rx.disposeBag)
        movie.map { "\($0?.videoLikeCount ?? 0)" }.asDriver(onErrorJustReturn: nil)
            .drive(countLabel.rx.text).disposed(by: rx.disposeBag)
 
        likeButton.rx.tap
            .debounce(DispatchTimeInterval.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: likeMovie)
            .disposed(by: rx.disposeBag)
        
        favoriteButton.rx.tap
            .bind(to: favoriteMovie)
            .disposed(by: rx.disposeBag)
        
        // 点击keyword
        collectionView.rx.modelSelected(String.self)
            .asObservable()
            .subscribe(onNext: { [weak self] keyword in
                let vc = SearchViewController.instanceFrom(storyboard: "Search")
                vc.defaultSearchText = keyword
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.invalidateLayout()
    }
    
    func bind(_ isLike: Driver<Bool>, isFavorited: Driver<Bool>, keywords: Driver<[String]>, likeCount: Driver<Int>) {
        likeCount.map({$0.toString()}).asDriver(onErrorJustReturn: nil)
            .drive(countLabel.rx.text).disposed(by: rx.disposeBag)
        isFavorited.drive(favoriteButton.rx.isSelected).disposed(by: rx.disposeBag)
        isLike.drive(likeButton.rx.isSelected).disposed(by: rx.disposeBag)
        keywords.asDriver()
            .drive(collectionView.rx.items(cellIdentifier: "\(TagCell.self)", cellType: TagCell.self)){
                index, viewModel, cell in
                cell.bind(text: viewModel)
            }
            .disposed(by: rx.disposeBag)
    }
//    func bind(_ movie: Driver<MovieDetail>) {
//        movie.map {$0.topicWatchMovieList?.first?.videoLikeCount ?? 0}.map{$0.toString()}
//            .drive(countLabel.rx.text).disposed(by: rx.disposeBag)
//        movie.map { $0.isLike == 1}.drive(likeButton.rx.isSelected).disposed(by: rx.disposeBag)
//        movie.map { $0.loginIsCollect == 1}.drive(favoriteButton.rx.isSelected).disposed(by: rx.disposeBag)
//        movie.map {$0.topicWatchMovieList?.first?.keywords ?? []}.asDriver()
//            .drive(collectionView.rx.items(cellIdentifier: "\(TagCell.self)", cellType: TagCell.self)){
//                index, viewModel, cell in
//                cell.bind(text: viewModel)
//            }
//            .disposed(by: rx.disposeBag)
//    }
}


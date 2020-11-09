//
//  MovieListOnTopicViewController.swift
//  TianXin
//
//  Created by pretty on 10/8/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import RxDataSources

class MovieListOnTopicViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let headerRefreshTrigger = PublishSubject<Void>()
    let isHeaderLoading = BehaviorRelay(value: false)
    var viewModel: MovieListOnTopicViewControllerModel?
    
    let offset = BehaviorRelay(value: 0)
    let headerHeight = 270 as CGFloat
    
    var currentOffset = 0 as CGFloat
    
    private var flowlayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        makeUI()
        collectionView.configureDataSetView(options: [.empty: "暂无数据"], isFullScreen: false)
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        isHeaderLoading.bind(to: collectionView.mj_header!.rx.isAnimation).disposed(by: rx.disposeBag)
        viewModel?.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        
        viewModel?.topic.map { $0.title }.asDriver(onErrorJustReturn: nil)
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        let input = MovieListOnTopicViewControllerModel.Input(
            headerRefresh: refresh,
            selection: collectionView.rx.modelSelected(TopicMovieListCellViewModel.self).asDriver()
        )
        let output = viewModel?.transform(input: input)
        // data source
        let dataSource = RxCollectionViewSectionedReloadDataSource<MovieListOnTopicViewController.SectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(for: indexPath) as TopicMovieListCell
                cell.bind(item)
                return cell
            },
            configureSupplementaryView: { item, collectionView, kind, indexPath in
                let header = collectionView.dequeueReusableHeaderView(for: indexPath) as MovieListOnTopicHeaderView
                header.bind(item[indexPath.section].topic)
                return header
            }
        )
        output?.items.map { [weak self] in
            guard let viewModel = self?.viewModel else { return [] }
            return [
                SectionModel(
                    original: SectionModel(items: $0, topic: TopicViewCellViewModel(with: viewModel.topic.value)),
                    items: $0)
            ]
        }.asDriver().drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        output?.loadDataState.filterNil().bind(to: collectionView.rx.loadDataState).disposed(by: rx.disposeBag)
        
        collectionView.rx.didScroll
            .asObservable()
            .flatMapLatest({ [weak self]() -> Observable<CGFloat> in
                guard let self = self else { return Observable.just(0) }
                self.currentOffset = self.collectionView.contentOffset.y
                let alpha = 1 - (self.headerHeight / 2.0 - self.collectionView.contentOffset.y) / (self.headerHeight / 2.0)
                return Observable.just(alpha)
            }).asDriver(onErrorJustReturn: 0)
            .drive(navigationController!.navigationBar.rx.alpha)
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.modelSelected(TopicMovieListCellViewModel.self)
            .asDriver()
            .drive(onNext: { [weak self] model in
                let vc = MovieDetailViewController.instanceFrom(storyboard: "Movie")
                vc.viewModel = MovieDetailViewControllerModel(movie: model.movie)
                self?.show(vc, sender: self)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func makeUI() {
        
        let itemWidth = (UIScreen.main.bounds.width
                            - flowlayout.minimumInteritemSpacing
                            - flowlayout.sectionInset.left
                            - flowlayout.sectionInset.right
        ) / 2.0
        let itemHeight = floor(itemWidth * 5 / 8 + 32)
        flowlayout.itemSize = .init(width: itemWidth, height: itemHeight)
        collectionView.contentInset = .init(top: -KnavHeight, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let alpha = 1 - (self.headerHeight  - self.collectionView.contentOffset.y) / self.headerHeight
        Observable.just(alpha).bind(to: navigationController!.navigationBar.rx.alpha).disposed(by: rx.disposeBag)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Observable.just(1.0 as CGFloat).bind(to: navigationController!.navigationBar.rx.alpha).disposed(by: rx.disposeBag)
    }
}

extension MovieListOnTopicViewController {
    struct SectionModel {
        var items: [TopicMovieListCellViewModel]
        var topic: TopicViewCellViewModel
    }
}

extension MovieListOnTopicViewController.SectionModel: SectionModelType {
    init(original: MovieListOnTopicViewController.SectionModel, items: [TopicMovieListCellViewModel]) {
        self = original
        self.items = items
    }
}

extension MovieListOnTopicViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = Configs.Dimensions.screenWidth
        let height = (190 as CGFloat).fitting
        return .init(width: width, height: ceil(height) + 60)
    }
}

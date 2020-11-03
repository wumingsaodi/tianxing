//
//  SearchViewController.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

class SearchViewController: UIViewController {
    lazy var searchBarController = SearchBarViewController.instanceFrom(storyboard: "Search")
    @IBOutlet weak var searchDefaultView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var flowlayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var searchDefaultController: SearchDefaultViewController? {
        return children.first { $0 is SearchDefaultViewController } as? SearchDefaultViewController
    }
    
    lazy var viewModel = SearchResultsViewModel()
    let searchText = PublishSubject<String>()
    let footerRefresh = PublishSubject<Void>()
    // 默认搜索关键字
    var defaultSearchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        // 点击最近搜索项
        searchDefaultController?.viewModel.onItemTap
            .asObservable()
            .bind(to: searchBarController.textField.rx.text)
            .disposed(by: rx.disposeBag)
        searchDefaultController?.viewModel.onItemTap
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: searchDefaultView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        // 点击搜索按钮
        searchBarController.searchButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.searchText.onNext(self.searchBarController.textField.text ?? "")
            })
            .disposed(by: rx.disposeBag)
        //
        searchBarController.textField.rx.text
            .asDriver()
            .map { $0?.isEmpty }
            .filterNil()
            .map { !$0 }
            .drive(searchDefaultView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        let input = SearchResultsViewModel.Input(
            searchText: searchText,
            footerRefresh: footerRefresh
        )
        let output = viewModel.transform(input: input)
        let dataSource = RxCollectionViewSectionedReloadDataSource<SearchSectionModel> { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(for: indexPath) as TopicMovieListCell
            cell.bind(item)
            return cell
        } configureSupplementaryView: { model, collectionView, kind, indexPath -> UICollectionReusableView in
            let view = collectionView.dequeueReusableHeaderView(for: indexPath) as SearchResultsViewHeader
            view.bind(model[indexPath.section].title)
            return view
        }
        
        output.items.map { [SearchSectionModel(title: "为您搜索到以下结果", items: $0)] }
            .asDriver()
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        output.items.map { $0.isEmpty }
            .asDriver()
            .drive(collectionView.rx.isEmptyData)
            .disposed(by: rx.disposeBag)
        output.items.drive(onNext: { [weak self] _ in
            self?.searchDefaultController?.viewModel.refresh.onNext(())
        }).disposed(by: rx.disposeBag)
        
        if let defaultSearchText = self.defaultSearchText {
            self.searchBarController.textField.text = defaultSearchText
            self.searchDefaultView.isHidden = true
            searchText.onNext(defaultSearchText)
        }
        // 点击cell
        collectionView.rx.modelSelected(TopicMovieListCellViewModel.self)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                let vc = MovieDetailViewController.instanceFrom(storyboard: "Movie")
                vc.viewModel = MovieDetailViewControllerModel(movie: model.movie)
                self?.navigationController?.pushViewController(vc, isNeedLogin: true, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func makeUI() {
        
        let searchBar = searchBarController.view!
        searchBar.frame = .init(x: 42.5, y: 0, width: Configs.Dimensions.screenWidth - 42.5, height: 44)
        
        collectionView.configureDataSetView(options: [.empty: "暂无结果"])
        
        let itemWidth = (UIScreen.main.bounds.width
                            - flowlayout.minimumInteritemSpacing
                            - flowlayout.sectionInset.left
                            - flowlayout.sectionInset.right
        ) / 2.0
        let itemHeight = floor(itemWidth * 5 / 8 + 32)
        flowlayout.itemSize = .init(width: itemWidth, height: itemHeight)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBarController.view.removeFromSuperview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(searchBarController.view)
    }
}

extension SearchViewController {
    struct SearchSectionModel {
        let title: String
        let items: [TopicMovieListCellViewModel]
    }
}
extension SearchViewController.SearchSectionModel: SectionModelType {
    init(original: SearchViewController.SearchSectionModel, items: [TopicMovieListCellViewModel]) {
        self.items = items
        self.title = "为您搜索到以下结果"
    }
}

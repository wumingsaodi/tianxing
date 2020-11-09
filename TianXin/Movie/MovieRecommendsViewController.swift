//
//  MovieRecommendsViewController.swift
//  TianXin
//
//  Created by pretty on 10/12/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieRecommendsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var flowLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    let itemSelected = PublishSubject<TopicMovieListCellViewModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        
        // 点击cell
        collectionView.rx.modelSelected(TopicMovieListCellViewModel.self)
            .asObservable()
            .bind(to: itemSelected)
            .disposed(by: rx.disposeBag)
    }
    
    func bind(_ items: Driver<[TopicMovieListCellViewModel]>) {
        items.asDriver()
            .drive(collectionView.rx.items(cellIdentifier: "\(TopicMovieListCell.self)", cellType: TopicMovieListCell.self)){
                index, viewModel, cell in
                cell.bind(viewModel)
            }.disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        
        let itemWidth = (UIScreen.main.bounds.width
                            - flowLayout.minimumInteritemSpacing
                            - flowLayout.sectionInset.left
                            - flowLayout.sectionInset.right
        ) / 2.0
        let itemHeight = floor(itemWidth * 5 / 8 + 32)
        flowLayout.itemSize = .init(width: itemWidth, height: itemHeight)
    }
    
    var itemHeight: CGFloat {
        return flowLayout.itemSize.height + flowLayout.minimumLineSpacing
    }
}

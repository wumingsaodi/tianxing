//
//  SearchDefaultViewController.swift
//  TianXin
//
//  Created by pretty on 10/10/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchDefaultViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var viewModel = SearchDefaultViewControllerModel()
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    let deleteAll = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout?.sectionInset = .init(top: 10, left: 20, bottom: 10, right: 20)
        flowLayout?.minimumLineSpacing = 0
        flowLayout?.minimumInteritemSpacing = 5
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView.configureDataSetView(options: [.empty: "暂无历史记录"])
        let input = SearchDefaultViewControllerModel.Input(
            deleteAll: deleteAll,
            modelSelected: collectionView.rx.modelSelected(RecentSearchCellViewModel.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        output.items.asDriver()
            .drive(collectionView.rx.items(cellIdentifier: "\(RecentSearchCell.self)", cellType: RecentSearchCell.self)) {
                index, viewModel, cell in
                cell.bind(viewModel)
            }
            .disposed(by: rx.disposeBag)
        output.items.map { $0.isEmpty ? UIView.LoadDataState.empty : UIView.LoadDataState.none }.asDriver()
            .drive(collectionView.rx.loadDataState)
            .disposed(by: rx.disposeBag)
    }

    @IBAction func onDeleteAll(_ sender: UIButton) {
        deleteAll.onNext(())
    }
    
}

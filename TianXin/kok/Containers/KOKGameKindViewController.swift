//
//  KOKGameKindViewController.swift
//  TianXin
//
//  Created by pretty on 10/22/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class KOKGameKindViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: KOKGameKindViewControllerModel?
    var isFirst = true
    
    lazy var flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(type: ImageCollectionViewCell.self)
        collectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirst {
            return
        }
        bindViewModel()
    }
    
    func bindViewModel() {
        guard let vm = self.viewModel else { return }
        let input = KOKGameKindViewControllerModel.Input()
        let output = vm.transform(input: input)
        output.items.drive(collectionView.rx.items(cellIdentifier: "\(ImageCollectionViewCell.self)", cellType: ImageCollectionViewCell.self)) {
            index, viewModel, cell in
            cell.imageView.image = UIImage(named: viewModel.enName.string)
        }.disposed(by: rx.disposeBag)
        output.items.map({$0.isEmpty})
            .drive(onNext: { [weak self] isEmpty in
                self?.isFirst = isEmpty
            })
            .disposed(by: rx.disposeBag)
    }

}

extension KOKGameKindViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel?.type == .真人 && indexPath.row > 0 {
            let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing
            let width = (Configs.Dimensions.screenWidth - spacing) / 2
            return .init(width: width, height: width)
        }
        let width = Configs.Dimensions.screenWidth - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        return .init(width: width, height: width * 0.5)
    }
}
// MARK: - VIEW MDOEL
class KOKGameKindViewControllerModel: NSObject, ViewModelType {
    
    let type: GameType
    init(type: GameType) {
        self.type = type
    }
    
    lazy var provider = HttpProvider<UserApi>.default
    let errMsg = PublishSubject<String>()
    
    struct Input {
    }
    struct Output {
        let items: Driver<[JSON]>
    }
    func transform(input: Input) -> Output {
        let items = BehaviorRelay<[JSON]>(value: [])
        // 请求数据
        UserApi.queryGameByType(gameType: self.type).request(provider: provider)
            .subscribe(onNext: { [weak self] json in
                guard let self = self else { return }
                if json.code.string != "success" {
                    self.errMsg.onNext(json.message.string)
                } else {
                    var list = json["data"][self.type.rawValue].array
                    list.sort(by: {$0.sort.int < $1.sort.int})
                    items.accept(list)
                }
            })
            .disposed(by: rx.disposeBag)
        return Output(
            items: items.asDriver()
        )
    }
}

/*
 "gameType": "ZR",
         "commissionRate": "",
         "sort": 201,
         "isDisplay": 0,
         "url": "",
         "createdAt": "",
         "zhName": "eBET真人",
         "enName": "EBETZR",
         "walletStatus": "",
         "channelName": "eBET真人",
         "gameTypeName": "",
         "id": 1,
         "category": 3,
         "configItem": {
           "venueTagOne": "0"
         },
         "venueTag": {
           "venueTagOne": "0"
         },
         "channelCode": "EBET",
         "status": 0,
         "updatedAt": ""
 */

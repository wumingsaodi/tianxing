//
//  UserReplyListCell.swift
//  TianXin
//
//  Created by pretty on 10/17/20.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserReplyListCell: RxTableViewCell<UserReplyListCellViewModel> {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var circleCollectionView: UICollectionView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeNumButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var labelWidthConstarint: NSLayoutConstraint!
    @IBOutlet weak var circleListHeightConstraint: NSLayoutConstraint!
    
    override func bind(_ model: UserReplyListCellViewModel) {
        super.bind(model)
        
        model.avatar.map{try? $0?.asURL()}.filterNil().asDriver(onErrorJustReturn: nil)
            .drive(avatarImageView.rx.imageURL).disposed(by: cellDisposeBag)
        model.name.asDriver().drive(nameLabel.rx.text).disposed(by: cellDisposeBag)
        model.content.asDriver().drive(contentLabel.rx.text).disposed(by: cellDisposeBag)
        model.originContent.asDriver().drive(commentLabel.rx.text).disposed(by: cellDisposeBag)
        model.time.asDriver().drive(timeLabel.rx.text).disposed(by: cellDisposeBag)
        model.likeNum.map{"\($0)"}.asDriver(onErrorJustReturn: nil)
            .drive(likeNumButton.rx.title()).disposed(by: cellDisposeBag)
        model.isLiked.asDriver().drive(likeNumButton.rx.isSelected).disposed(by: cellDisposeBag)
        model.hasPhoto.map{$0 ? "【图片】" : ""}.asDriver(onErrorJustReturn: nil)
            .drive(typeLabel.rx.text).disposed(by: cellDisposeBag)
        model.hasPhoto.map{$0 ? 62 : 16}.asDriver(onErrorJustReturn: 16)
            .drive(labelWidthConstarint.rx.constant).disposed(by: cellDisposeBag)
        
        
        cellDisposeBag = DisposeBag()
        model.circles.asDriver().drive(circleCollectionView.rx.items(cellIdentifier: "\(CircleNameListCell.self)", cellType: CircleNameListCell.self)){
            index, viewModel, cell in
            cell.bind(viewModel)
        }.disposed(by: cellDisposeBag)
        
        model.circles.map{$0.isEmpty ? 0 : 30}.asDriver(onErrorJustReturn: 0)
            .drive(circleListHeightConstraint.rx.constant).disposed(by: cellDisposeBag)
    }
}

extension CircleNameListCell {
    func bind(_ json: JSON) {
        self.label.text = json.recommendName.string
    }
}

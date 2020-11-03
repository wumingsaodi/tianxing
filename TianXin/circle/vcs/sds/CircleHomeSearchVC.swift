//
//  CircleHomeSearchVC.swift
//  TianXin
//
//  Created by SDS on 2020/10/30.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class CircleHomeSearchVC: SDSBaseVC {
    let footerRefreshTrigger = PublishSubject<Void>()
    lazy var vm:CircleHomeSearchVCViewModel = {
         return  CircleHomeSearchVCViewModel()
    }()
    var models = BehaviorRelay<[CircleHomeModel]>(value: [])
    var searchSub = PublishSubject<String?>()
    
    lazy var searchView:CircleHomeSearchLastView = {
        let last =  CircleHomeSearchLastView()
        last.selectedTitle.bind(to: searchBar.textF.rx.text).disposed(by: rx.disposeBag)
        return last
    }()
    lazy var searchBar:SearchBar = {
        return SearchBar()
    }()
    lazy var tableView:SDSTableView = {
        let tableView = SDSTableView()
        tableView.addSubview(tableView.noDataView)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.registerClass(type: CircleHomeSearchTableCell.self)
        tableView.registerNib(type: CircleHomeSearchTableCell.self)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
         
        tableView.isHidden = true
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        setNav()
        tableView.mj_footer = MJRefreshAutoNormalFooter { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        }
        
        tableView.rx.modelSelected(CircleHomeModel.self).subscribe(onNext: {[weak self] model in
            //
            let vc = IssueDetailViewController.`init`(withIssueId: model.issueId)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        models.asDriver().drive(tableView.rx.items(cellIdentifier: "\(CircleHomeSearchTableCell.self)", cellType: CircleHomeSearchTableCell.self)) {index,model,cell in
            cell.AddOrNoAddSubJet.subscribe(onNext: {[weak self] model in
                guard let self = self else{
                    return
                }
                var modelArr = self.models.value
                modelArr[index] = model
                self.models.accept(modelArr)
            }).disposed(by: self.rx.disposeBag)
            cell.model = model
//            print(viewmodel)
        }.disposed(by: rx.disposeBag)
        models.map { $0.isEmpty }.bind(to: tableView.rx.noData).disposed(by: rx.disposeBag)
        
        
        let input = CircleHomeSearchVCViewModel.Input(
            searchText:searchSub.asObserver(),
            footerRefresh: footerRefreshTrigger
        )
        let out =    vm.transform(input: input)
        out.searchmodels.drive(onNext: {[weak self] (models) in
            self?.models.accept(models)
        }).disposed(by: rx.disposeBag)
        
        vm.noMoreData.bind(to: tableView.rx.noMoreData).disposed(by: rx.disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
//        setNav()
    }
    func setNav(){
        self.navigationItem.titleView = searchBar
//        self.navigationController?.navigationBar.addSubview(searchBar)
//        searchBar.frame = CGRect(x:(KScreenW - searchBar.sdsW)*0.5 , y: 0, width: searchBar.sdsW, height: searchBar.sdsH)
////        searchView
        self.view.addSubview(searchBar)
        searchBar.snp.remakeConstraints { (make) in
            make.size.equalTo(searchBar.sdsSize)
            make.centerX.equalToSuperview()
             make.centerY.equalTo(kStatueH + 22)
        }
        
        let but = UIButton.createButWith(title: "搜素", titleColor: .Hex("#FF87827D"), font: .pingfangSC(15)) {[weak self](but) in
            self!.tableView.isHidden = false
            self!.searchView.isHidden = true
            self?.searchSub.onNext(self?.searchBar.textF.text)
        }
        but.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
//        shousuoBut = but
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: but)
        
     
    }
//    var shousuoBut:UIButton!
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.view.addSubview(searchBar)
//    }
    func setUI() {
//        self.view.addSubview(searchBar)
//        searchBar.snp.makeConstraints { (make) in
//            make.size.equalTo(searchBar.sdsSize)
//            make.top.equalToSuperview().offset(kStatueH)
//            make.centerX.equalToSuperview()
//        }
        
        
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
extension CircleHomeSearchVC:UITableViewDelegate{
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147.5
    }
}
//

extension Reactive where Base: SDSTableView {
    var noData: Binder<Bool> {
        return Binder<Bool>(self.base) {
            tableView, noData in
            tableView.noDataView.isHidden = !noData
        }
    }
}

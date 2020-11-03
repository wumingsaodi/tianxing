//
//  HomeSearchVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/21.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class HomeSearchVC: SDSBaseVC {
    var models:[searchVideoModel] = [searchVideoModel]()
    var currPage:Int = 0
    var keyWord:String = ""{
        didSet{
            if let index =    searchTitles.firstIndex(of: keyWord){
                searchTitles.remove(at: index)
            }
            searchTitles.insert(keyWord, at: 0)
        }
        
    }
    var isNotMore:Bool = false
    var searchTitles:[String] = [String](){
        didSet{//最多显示九条搜索记录
            let arr = searchTitles.count <= 9 ? searchTitles : Array(searchTitles[0...8])
            UserDefaults.standard.setValue(arr, forKey: LastestVideoSearchArrKey)
            remenView.titles = arr
        }
    }
    lazy var  vm:HomeVideoSearchViewModel = {
        return HomeVideoSearchViewModel()
    }()
    lazy var searchView:SearchBar = {
        let search = SearchBar()
        return search
    }()
    lazy var remenView:RemenSearch = {
        var titles:[String] = searchTitles
        let remen = RemenSearch.init(frame: .zero, titles: titles) {[weak self] (seletedText) in
            self!.searchView.textF.text = seletedText
        }
        return remen
    }()
    lazy var tableV:SDSTableView = {
        let table = SDSTableView.CreateTableView().sdsRegisterCell(cellClass: "searchTableCell", isNib: true, cellBlock: { [weak self](index, cell) in
            let ncell = cell as! searchTableCell
            ncell.setModel(model: self!.models[index.row])
            
        }, height: { (index) -> CGFloat in
            return 115
        }).sdsNumOfRows(block: { (num) -> Int in
            return self.models.count
        }).sdsRegisterHeader(headerClass: "UITableViewHeaderFooterView", headerBlock: { [weak self](_, header) in
          
            header.addSubview(self!.headLab)
            self!.headLab.text = "为您搜索到\(self!.models.count)条影片"
            header.contentView.backgroundColor = .white
            self!.headLab.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }, height: { (_) -> CGFloat in
            return 44
        }).sdsDidSelectCell { (indexpath) in
            let item = self.models[indexpath.row]
            HomeDetailViewMoodel().requistMovieDetail(id: item.id) { (model) in
                let vc = HomeDetailVC()
                vc.model = model
                self.navigationController?.pushViewController(vc,isNeedLogin: true, animated: true)
            }
        }.sdsMJRerechBlock {[weak self] (ishead) in
            if !ishead{
                self?.requestDataList(keyWord: self?.searchView.textF.text ?? "")
            }
        }
        table.separatorStyle = .none
        table.isHidden = true
        return table
    }()
    lazy var headLab:UILabel = {
        let lab = UILabel.createLabWith(title: "为您搜索0条影片", titleColor: .Hex("#3C3729"), font: .pingfangSC(14), aligment: .center)
        return lab
    }()
    override func viewDidLoad() {
          super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = .Hex("#FFF7F8FC")
        self.searchTitles = UserDefaults.standard.value(forKey: LastestVideoSearchArrKey) as? [String] ?? [String]()
          setNav()
        //
        self.view.addSubview(remenView)
        remenView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(KnavHeight + 10)
            make.left.right.bottom.equalToSuperview()
        }
        self.view.addSubview(tableV)
        tableV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(KnavHeight + 15)
        }
      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func setNav() {
       
        self.navigationItem.titleView = searchView
//        searchView.frame = CGRect(x: 0, y: 0, width: searchView.sdsW, height: searchView.sdsH)
        self.view.addSubview(searchView)
        searchView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(kStatueH + 22)
            make.height.equalTo(searchView.sdsH)
            make.width.equalTo(scaleX(searchView.sdsW))
//            make.left.equalToSuperview().offset(50)
//            make.right.equalToSuperview().offset(-50)
        }
        let but = UIButton.createButWith(title: "搜索", titleColor: UIColor.Hex("#FF87827D"),font: .pingfangSC(15)) {[weak self] (_) in
            self?.requestDataList(keyWord: self?.searchView.textF.text ?? "")
            //网络请求
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: but)
    }
    func requestDataList(keyWord:String){
        if keyWord.count <= 0 {
            SDSHUD.showError("搜索不能为空")
            return
        }
        if self.keyWord != keyWord {
            currPage = 0
        }
        vm.requestSearchVideo(keyWord: keyWord, currPage: self.currPage) {[weak self] (models,isnotMore) in
            if self!.keyWord != keyWord {
                self?.keyWord = keyWord
            }
            
            if models.count <= 0 {
                if self!.currPage  == 0{
                    self?.models = models
                    self?.tableV.isHidden = true
                    self?.remenView.isHidden = false
                }
              
                return
            }
            if self!.currPage  == 0{
                self?.models = models
            }else{
                self?.models.append(contentsOf: models)
            }
            self?.tableV.isHidden = false
            self?.remenView.isHidden = true
            self?.tableV.reloadData()
            self?.currPage += 1
        }
    }
}

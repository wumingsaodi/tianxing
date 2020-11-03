//
//  TianXingQianBaoVC.swift
//  TianXin
//
//  Created by SDS on 2020/9/30.
//  Copyright © 2020 SDS. All rights reserved.
//

import UIKit

class TianXingQianBaoVC: SDSBaseVC {

    @IBOutlet weak var selectedLine: UIView!
    @IBOutlet weak var helpBut: UIButton!
    var orderType:Int = 1
    var isOrderNomore:Bool = false
    var isChangeNomore:Bool = false
    var orderModels:[OrderModel] = [OrderModel]()
    var changeModels:[OrderModel] = [OrderModel]()
    var orderPage:Int = 1
    var changePage: Int = 1
//    @IBOutlet weak var nodataV: UIView!
    lazy var vm:MoneyRecordViewModel = {
        return MoneyRecordViewModel()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
         self.helpBut.backgroundColor = UIColor.init(white: 1, alpha: 0.33)
        helpBut.cornor(conorType: UIRectCorner(arrayLiteral: .topLeft,.bottomLeft), reduis: 17)
//        self.setBackImg(name: "back_white", hideNav: true)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kBottomSafeH)
            make.top.equalTo(selectedLine.snp.bottom).offset(3)
        }
      getOrder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setWhiteBackImg( hideNav: true)
    }
    lazy var tableView:SDSTableView = {
        let tab = SDSTableView.CreateTableView().sdsNumOfRows(block: { [weak self] (section) -> Int in
            if self!.orderType  == 1 {
                return self!.orderModels.count
            }
            return   self!.changeModels.count
        }).sdsRegisterCell(cellClass: "OrderListCell",isNib: true) {[weak self] (indePath, cell) in
          let ncell = cell as! OrderListCell
            let model = self?.orderType == 1 ? self?.orderModels[indePath.row] :
                self?.changeModels[indePath.row]
            let isOrder = self?.orderType == 1 ? true : false
            ncell.setModel(model: model!, isOder: isOrder)
            
        } height: { (idexPath) -> CGFloat in
            return 80
        }.sdsMJRerechBlock(isCanHeard: true) {[weak self] (ishead) in
            let isNomore:Bool = self!.orderType == 1 ? self!.isOrderNomore : self!.isChangeNomore
            if(!ishead&&isNomore){
                self?.tableView.mj_footer?.endRefreshing()
                self?.tableView.mj_header?.endRefreshing()
                return
            }
            if ishead{
                if self?.orderType == 1 {
                    self?.orderPage = 1
                }else{
                    self?.changePage = 1
                }
            }
            self?.getOrder()
        }

//        tab.backgroundColor = .yellow
        return tab
    }()
 
    @IBAction func zhuanzhangButClick(_ sender: UIButton) {
        
        let vc = KOKMoneyVC.init(nibName: "KOKMoneyVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func chongzhiButClick(_ sender: UIButton) {
        let vc = RechargeVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

     @IBAction func helpBuTclick(_ sender: UIButton) {
        
     }
    @IBAction func keFuButClick(_ sender: UIButton) {
        let vc = KefuVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - Navigation

    @IBAction func titleButClick(_ sender: UIButton) {
       if self.selectedLine.center.x == sender.center.x
        {
         return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.selectedLine.center.x = sender.center.x
        }
        if sender.currentTitle == "存款" {
            self.orderType = 1
        }else{
            self.orderType = 2
            if !isChangeRequist {
                getOrder()
                isChangeRequist = true
            }
        }
        self.tableView.reloadData()
    }
    var isChangeRequist:Bool = false
}

extension TianXingQianBaoVC  {
    func getOrder(){
        let page = self.orderType == 1 ? orderPage : changePage
        vm.requiestOrderList(ordertype: self.orderType, pageNumber: page) {[weak self] (models, isnomore) in
          
            if self!.orderType == 1 {
                if page == 1 {//刷新
                    self?.orderModels = models
                }else{
                    self?.orderModels.append(contentsOf: models)
                }
                self?.isOrderNomore = isnomore
            }else{
                if page == 1 {//刷新
                    self?.changeModels = models
                }else{
                    self?.changeModels.append(contentsOf: models)
                }
                self?.isChangeNomore = isnomore
            }
            self?.tableView.reloadData()
        }
    }
}

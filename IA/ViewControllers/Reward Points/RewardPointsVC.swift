//
//  RewardPointsVC.swift
//  IA
//
//  Created by admin on 23/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class RewardPointsVC: BaseClassVC {
    
    @IBOutlet weak var tableRewards: UITableView!
    @IBOutlet weak var lblRewards: UILabel!
    let viewModel = RewardsViewModel(dataService: ApiClient())
    var rewardPoints : [RewardPointsModel] = []
    var offset = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchRewardsPoint(1)
    }
    
    func setupUI() {
        self.headerTitle.text = "Reward Points"
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
    }
    
    
    
    private func fetchRewardsPoint(_ offset: Int) {
        
        let url = "\(URLMethods.rewardPoints)?page_no=\(offset)"
        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            
            if offset <= 1 {
                self.offset = offset
                self.rewardPoints.removeAll()
                self.tableRewards.setContentOffset(.zero, animated:true)
            }
            self.rewardPoints.append(contentsOf: self.viewModel.rewards!)
            self.lblRewards.text = "\(self.viewModel.totalRewards) Points"
            self.tableRewards.reloadData()
            
        }
        
    }
    
}



extension RewardPointsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = rewardPoints.count
        tableView.setBackgroundMessage(rows == 0 ? "No data found" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRewards", for: indexPath) as! RewardsCell
        cell.data = rewardPoints[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == self.rewardPoints.count-4 {
            
            if viewModel.isReload! {
                print(viewModel.isReload!)
                offset = offset + 1
                self.fetchRewardsPoint(offset)
                viewModel.isReload! = false
            }
        }
    }
}

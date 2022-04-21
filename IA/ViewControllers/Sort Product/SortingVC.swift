//
//  SortingVC.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

struct Sorting {
    public var title : String?
    public var sortStatus : String?
    public var index : Int?
}

class SortingVC: UIViewController {
    
    @IBOutlet weak var tableViewSort: UITableView!
    @IBOutlet weak var viewRadius: UIView!
    
    var sortingMode : [Sorting] = [
    Sorting(title: "Popularity", sortStatus: "", index: 0),
    Sorting(title: "Price - Low to High", sortStatus: "price_low_to_high", index: 1),
    Sorting(title: "Price - High to Low", sortStatus: "price_high_to_low", index: 2),
    Sorting(title: "Newest First", sortStatus: "newest", index: 3)]
    var sortStatus  = ""
    var callback : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TableViewCellSort", bundle: nil)
        tableViewSort.register(nib, forCellReuseIdentifier: "cellSort")
        
        let filtered = sortingMode.filter({ $0.sortStatus == sortStatus})
        let indexpath = IndexPath(row: filtered[0].index ?? 0, section: 0)
        tableViewSort.selectRow(at: indexpath, animated: false, scrollPosition: .none)
        
    }
    
    override func viewDidLayoutSubviews() {
        viewRadius.roundCorners(corners: [.topLeft, .topRight], radius: 35.0)
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SortingVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortingMode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSort", for: indexPath) as! TableViewCellSort
        cell.lblTitle.text = sortingMode[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            let status = self.sortingMode[indexPath.row].sortStatus
            self.callback!(status ?? "")
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//
//  FAQVC.swift
//  Footprint
//
//  Created by Yogesh Raj on 3/31/20.
//  Copyright © 2020 Yogesh Raj. All rights reserved.
//

import UIKit

class FAQVC: BaseClassVC {

    @IBOutlet weak var tableView : UITableView!
    
    var webTitle = ""
    var faqArray:[FAQDataModel] = []
    var indexArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.headerTitle.text = webTitle
        self.menuBtn.isHidden = false
        getContent("faq")
        
    }
    
    //MARK:-  get Content Data
    
    func getContent(_ key: String) {
    
        AppManager.startActivityIndicator()
        
        let url = "\(URLMethods.staticPages)\(key)"
        ApiClient().apiCallMethod(url, method: .get, parameter: [:], successClosure: { (response) in
                
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data.content_data") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.faqArray = try! jsonDecoder.decode([FAQDataModel].self, from: jsonData!)
            self.tableView.reloadData()
            
        }) { (error) in
            AppManager.showToast(error ?? "")
        }
    }

}

// MARK: - <UITableViewDelegate> / <UITableViewDataSource>
extension FAQVC : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = self.faqArray.count
        tableView.setBackgroundMessage(rows == 0 ? "No data found" : nil)
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = faqArray[indexPath.row]
        if indexArray.contains(indexPath.row) == true {
            
            let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell1")!
            let ques = cell.viewWithTag(1) as? UILabel
            let ans = cell.viewWithTag(2) as? UILabel
            
            ques?.text = "Q\(indexPath.row + 1) : " + "\(data.question ?? "")"
            ans?.text = "A\(indexPath.row + 1) : " + "\(data.answer ?? "")"
            
             return cell
            
        } else {
            
            let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell2")!
            let ques = cell.viewWithTag(1) as? UILabel
            
            ques?.text = "Q\(indexPath.row + 1) : " + "\(data.question ?? "")"
            
             return cell
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexArray.contains(indexPath.row) == false {
            indexArray.add(indexPath.row)
        } else {
            indexArray.remove(indexPath.row)
        }
        self.tableView.reloadData()
    }

}


// MARK: - FAQDataModel
struct FAQDataModel: Codable {
    var questionID, question, answer: String?

    enum CodingKeys: String, CodingKey {
        case questionID = "question_id"
        case question, answer
    }
}

//
//  ThirdViewController.swift
//  TheKosherApp
//
//  Created by Rajan Marathe on 14/10/18.
//  Copyright © 2018 Rajan Marathe. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "About"
        }
        else if indexPath.row == 1 {
            cell.textLabel?.text = "Contact"
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let objAboutAndContactViewController = storyboard.instantiateViewController(withIdentifier: "AboutAndContactViewController") as! AboutAndContactViewController
        if indexPath.row == 0 {
            objAboutAndContactViewController.isAboutPage = true
        }
        else if indexPath.row == 1 {
            objAboutAndContactViewController.isAboutPage = false
        }
        self.navigationController?.pushViewController(objAboutAndContactViewController, animated: true)
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

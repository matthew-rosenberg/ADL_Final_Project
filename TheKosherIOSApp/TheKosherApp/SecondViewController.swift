//
//  SecondViewController.swift
//  TheKosherApp
//
//  Created by Rajan Marathe on 14/10/18.
//  Copyright © 2018 Rajan Marathe. All rights reserved.
//

import UIKit
import MessageUI

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var agencyListArr = [[String : Any]]()
    
    
    var thereIsCellTapped = false
    var selectedRowIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = Bundle.main.url(forResource: "Agencies", withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData) as! [[String : Any]]
            let sortedArray = (json as NSArray).sortedArray(using: [NSSortDescriptor(key: "real name", ascending: true)]) as! [[String:AnyObject]]

            agencyListArr = sortedArray
            let question1 = json[0]
                print( question1["phone"] as! String)
          
            
            let question2 = json[1]
                print( question2["phone"] as! String)
           
        }
        catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutSubviews()
        self.tableView.reloadData()
    }
    
    @objc func callButtonPressed ( sender : UIButton! ) {
        let agencyDict = agencyListArr[sender.tag]
        let strPhoneNumber = (agencyDict ["phone"] as! String)
        if !strPhoneNumber.isEmpty {
            if let phoneCallURL = URL(string: "tel://\(strPhoneNumber)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @objc func emailButtonPressed ( sender : UIButton! ) {
        let agencyDict = agencyListArr[sender.tag]
        let strEmailAddress = (agencyDict ["email"] as! String)
        
        if !strEmailAddress.isEmpty {
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.setToRecipients([strEmailAddress])
                composeVC.setSubject("Hello!")
                composeVC.setMessageBody("\n\n\n\n\n\n\n\nSent from The Kosher App!", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func websiteButtonPressed ( sender : UIButton! ) {
        let agencyDict = agencyListArr[sender.tag]
        let strWebsiteAddress = (agencyDict ["website"] as! String)
        if !strWebsiteAddress.isEmpty {
            guard let url = URL(string: strWebsiteAddress) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agencyListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KosherTableViewCell", for: indexPath) as! KosherTableViewCell
        
        let agencyDict = agencyListArr[indexPath.row]
        cell.agencyNameLabel.text = (agencyDict ["real name"] as! String).isEmpty ? "Not Available" : (agencyDict ["real name"] as! String)
        let heightOfAgencyName = heightForLabel(text: cell.agencyNameLabel.text!, font: UIFont.boldSystemFont(ofSize: 14), width: cell.agencyNameLabel.frame.width)
        if heightOfAgencyName > 20 {
            cell.constraintHeightOfAgencyNameLabel.constant  = 34
        } else {
            cell.constraintHeightOfAgencyNameLabel.constant = 17
        }
        
        var strAddress = "Not Available"
        if (agencyDict ["City"] as! String).isEmpty && !(agencyDict ["State"] as! String).isEmpty {
            strAddress = (agencyDict ["State"] as! String)
        } else if !(agencyDict ["City"] as! String).isEmpty && (agencyDict ["State"] as! String).isEmpty {
            strAddress = (agencyDict ["City"] as! String)
        } else if !(agencyDict ["City"] as! String).isEmpty && !(agencyDict ["State"] as! String).isEmpty {
            strAddress = (agencyDict ["City"] as! String) + ", " + (agencyDict ["State"] as! String)
        }
        
        let cRcText = (agencyDict ["CRC Approved"] as! String == "y") ? "cRc Approved" : " "
        
        cell.agencyAddressLabel.text = strAddress
        cell.isCRCApprovedLabel.text = cRcText
        
        let imageStr = (agencyDict ["Logo File Name"] as! String)
        let image = UIImage(named: imageStr)
        cell.agencyImageView.image = image
        
        if indexPath.row == selectedRowIndex && thereIsCellTapped {
            cell.constraintBottomContainarViewToCell.constant = 6
            cell.constraintTopStackView.constant = 10
            cell.constraintBottomStackView.constant = 10
            cell.callButton.isHidden = false
            cell.emailButton.isHidden = false
            cell.websiteButton.isHidden = false
            cell.lightBlueView.backgroundColor = UIColor(red: 0, green: 165/255, blue: 255/255, alpha: 0.1)
        } else {
            cell.constraintBottomContainarViewToCell.constant = 0
            cell.constraintTopStackView.constant = 0
            cell.constraintBottomStackView.constant = 0
            cell.callButton.isHidden = true
            cell.emailButton.isHidden = true
            cell.websiteButton.isHidden = true
            cell.lightBlueView.backgroundColor = UIColor.white
        }
        
        cell.callButton.tag = indexPath.row
        cell.emailButton.tag = indexPath.row
        cell.websiteButton.tag = indexPath.row
        cell.callButton.addTarget(self, action: #selector(self.callButtonPressed(sender:)), for: .touchUpInside)
        cell.emailButton.addTarget(self, action: #selector(self.emailButtonPressed(sender:)), for: .touchUpInside)
        cell.websiteButton.addTarget(self, action: #selector(self.websiteButtonPressed(sender:)), for: .touchUpInside)
        
        if (agencyDict ["phone"] as! String).isEmpty {
            cell.callButton.alpha = 0.25
            cell.callButton.isUserInteractionEnabled = false
        } else {
            cell.callButton.alpha = 1.0
            cell.callButton.isUserInteractionEnabled = true
        }
        if (agencyDict ["email"] as! String).isEmpty {
            cell.emailButton.alpha = 0.25
            cell.emailButton.isUserInteractionEnabled = false
        } else {
            cell.emailButton.alpha = 1.0
            cell.emailButton.isUserInteractionEnabled = true
        }
        if (agencyDict ["website"] as! String).isEmpty {
            cell.websiteButton.alpha = 0.25
            cell.websiteButton.isUserInteractionEnabled = false
        } else {
            cell.websiteButton.alpha = 1.0
            cell.websiteButton.isUserInteractionEnabled = true
        }
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex && thereIsCellTapped {
            return 177
        }
        return 107
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // avoid paint the cell is the index is outside the bounds
        if self.selectedRowIndex != -1 {
            self.tableView.cellForRow(at: NSIndexPath(row: self.selectedRowIndex, section: 0) as IndexPath)?.backgroundColor = UIColor.white
        }
        
        if selectedRowIndex != indexPath.row {
            self.thereIsCellTapped = true
            self.selectedRowIndex = indexPath.row
        }
        else {
            // there is no cell selected anymore
            self.thereIsCellTapped = false
            self.selectedRowIndex = -1
        }
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: false)
    }
}

func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
{
    let label:UILabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

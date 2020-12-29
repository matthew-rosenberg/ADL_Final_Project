//
//  AboutAndContactViewController.swift
//  TheKosherApp
//
//  Created by Rajan Marathe on 25/10/18.
//  Copyright © 2018 Rajan Marathe. All rights reserved.
//

import UIKit

class AboutAndContactViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactTextview: UITextView!
    @IBOutlet weak var aboutTextview: UITextView!
    var isAboutPage = true
    let strAbout = "The Kosher App is in development"
    let strContact = "To contact me about any concerns, problems, ideas, or just say hi please email at kosherapp0@gmail.com"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.aboutTextview.textContainerInset = UIEdgeInsets(top: 20, left: 8, bottom: 15, right: 8)
        self.contactTextview.textContainerInset = UIEdgeInsets(top: 20, left: 8, bottom: 15, right: 8)
        
        self.aboutTextview.text = strAbout
        self.contactTextview.text = strContact
        
        self.aboutTextview.isEditable = false
        self.contactTextview.isEditable = false
        
        if isAboutPage {
            self.titleLabel.text = "About"
            self.aboutTextview.isHidden = false
            self.contactTextview.isHidden = true
        } else {
            self.titleLabel.text = "Contact"
            self.aboutTextview.isHidden = true
            self.contactTextview.isHidden = false
        }
        
        let topBorder1 = CALayer()
        let topHeight1 = CGFloat(1.0)
        topBorder1.borderColor = UIColor.gray.cgColor
        topBorder1.frame = CGRect(x: 0, y: 0, width:  self.aboutTextview.frame.size.width, height: topHeight1)
        topBorder1.borderWidth = self.aboutTextview.frame.size.width
        self.aboutTextview.layer.addSublayer(topBorder1)
        
        let bottomBorder1 = CALayer()
        let borderHeight1 = CGFloat(1.0)
        bottomBorder1.borderColor = UIColor.gray.cgColor
        bottomBorder1.frame = CGRect(x: 0, y: self.aboutTextview.frame.size.height - borderHeight1, width:  self.aboutTextview.frame.size.width, height: borderHeight1)
        bottomBorder1.borderWidth = self.aboutTextview.frame.size.width
        self.aboutTextview.layer.addSublayer(bottomBorder1)
        self.aboutTextview.layer.masksToBounds = true

        let topBorder2 = CALayer()
        let topHeight2 = CGFloat(1.0)
        topBorder2.borderColor = UIColor.gray.cgColor
        topBorder2.frame = CGRect(x: 0, y: 0, width:  self.contactTextview.frame.size.width, height: topHeight2)
        topBorder2.borderWidth = self.contactTextview.frame.size.width
        self.contactTextview.layer.addSublayer(topBorder2)
        
        let bottomBorder2 = CALayer()
        let borderHeight2 = CGFloat(1.0)
        bottomBorder2.borderColor = UIColor.gray.cgColor
        bottomBorder2.frame = CGRect(x: 0, y: self.contactTextview.frame.size.height - borderHeight2, width:  self.contactTextview.frame.size.width, height: borderHeight2)
        bottomBorder2.borderWidth = self.contactTextview.frame.size.width
        self.contactTextview.layer.addSublayer(bottomBorder2)
        self.contactTextview.layer.masksToBounds = true
        
        self.contactTextview.dataDetectorTypes = .all
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

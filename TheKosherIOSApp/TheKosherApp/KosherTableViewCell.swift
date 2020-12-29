//
//  KosherTableViewCell.swift
//  TheKosherApp
//
//  Created by Rajan Marathe on 23/10/18.
//  Copyright © 2018 Rajan Marathe. All rights reserved.
//

import UIKit

class KosherTableViewCell: UITableViewCell {

    @IBOutlet weak var lightBlueView: UIView!
    @IBOutlet weak var agencyNameLabel: UILabel!
    @IBOutlet weak var constraintHeightOfAgencyNameLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomContainarViewToCell: NSLayoutConstraint!
    @IBOutlet weak var constraintTopStackView: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomStackView: NSLayoutConstraint!
    @IBOutlet weak var agencyAddressLabel: UILabel!
    @IBOutlet weak var isCRCApprovedLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var agencyImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

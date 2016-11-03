//
//  AblumListTableViewCell.swift
//  PH
//
//  Created by qmc on 16/11/2.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

import UIKit

class AblumListTableViewCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

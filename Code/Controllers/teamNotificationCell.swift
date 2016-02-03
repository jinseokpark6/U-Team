//
//  teamNotificationCell.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 9. 3..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

class teamNotificationCell: UITableViewCell {

	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

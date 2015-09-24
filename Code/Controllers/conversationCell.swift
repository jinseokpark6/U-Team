//
//  conversationCell.swift
//  UniversiTeam2
//
//  Created by Jin Seok Park on 2015. 8. 8..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

class conversationCell: UITableViewCell {

	@IBOutlet weak var profileImg: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var profileIdLabel: UILabel!

	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		profileImg.layer.cornerRadius = profileImg.frame.width / 2
		profileImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

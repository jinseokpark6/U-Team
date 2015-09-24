//
//  groupCell.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 2015. 6. 7..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

class groupCell: UICollectionViewCell {

    @IBOutlet weak var plusSign: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var teamLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
		imageView.contentMode = UIViewContentMode.ScaleAspectFill
		imageView.layer.borderWidth = 0.3
		
		teamLabel.layer.cornerRadius = teamLabel.frame.size.width/2
		teamLabel.clipsToBounds = true
		teamLabel.contentMode = UIViewContentMode.ScaleAspectFill
		teamLabel.layer.borderWidth = 0.3
		
		textLabel.backgroundColor = UIColor(red: 69.0/255, green: 175.0/255, blue: 220.0/255, alpha: 1)

    }

}

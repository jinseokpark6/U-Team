//
//  calendarCell.swift
//  UniversiTeam2
//
//  Created by Jin Seok Park on 2015. 7. 5..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

class calendarCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

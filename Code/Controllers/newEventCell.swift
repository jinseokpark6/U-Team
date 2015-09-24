//
//  newEventCell.swift
//  UniversiTeam2
//
//  Created by Jin Seok Park on 2015. 7. 6..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

class newEventCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet var placeholder: UITextField!
	
	@IBOutlet weak var textField: UITextField!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		textField.sizeToFit()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	
	func textFieldDidBeginEditing(textField: UITextField) {
		
		textField.becomeFirstResponder()
		
		let touch = UITouch()
		var location = touch.locationInView(touch.view)
		println("asdf \(location)")
	}
	

}

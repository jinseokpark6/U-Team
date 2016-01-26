//
//  profileCell.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 9. 1..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

class profileCell: UITableViewCell, UITextFieldDelegate {

	@IBOutlet weak var textField: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func textFieldDidBeginEditing(textField: UITextField) {
		
		print("hiya")
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		
		print("hi")
	}
	
	func keyboardWillHide(notification:NSNotification) {
		
		let dict:NSDictionary = notification.userInfo!
		let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let rect:CGRect = s.CGRectValue()
	}

}

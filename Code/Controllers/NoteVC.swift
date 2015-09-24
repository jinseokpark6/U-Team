//
//  NoteVC.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 9. 3..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

var noteText = ""

class NoteVC: UIViewController, UITextViewDelegate {

	
	
	@IBOutlet weak var saveBtn: UIBarButtonItem!
	@IBOutlet weak var textView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if !isEditing {
			self.saveBtn.tintColor = UIColor.clearColor()
			self.saveBtn.enabled = false
		} else {
			self.saveBtn.tintColor = UIColor.whiteColor()
			self.saveBtn.enabled = true
		}
		
		self.textView.layer.borderWidth = 1.0
		self.textView.layer.cornerRadius = 3

		self.automaticallyAdjustsScrollViewInsets = false


        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool) {
		
		self.textView.text = noteText
	}
	
	func textViewDidChange(textView: UITextView) {
		
		noteText = textView.text
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func saveBtn_click(sender: AnyObject) {
		
		
		if isEditing {
			
			var query = PFQuery(className:"Schedule")
			query.whereKey("objectId", equalTo: selectedEvent[0].objectId!)
			query.getFirstObjectInBackgroundWithBlock({ (object:PFObject?, error:NSError?) -> Void in
				
				if error == nil {
					
					object!["Description"] = self.textView.text
					object!.saveInBackgroundWithBlock({ (success, error) -> Void in
						if error == nil {
							println("success")
						}
					})
				}
			})
		}
	}
	
	public override func supportedInterfaceOrientations() -> Int {
		return UIInterfaceOrientation.Portrait.rawValue
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

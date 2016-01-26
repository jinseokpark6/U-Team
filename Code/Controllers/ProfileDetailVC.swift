//
//  ProfileDetailVC.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 9. 1..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

class ProfileDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

	var layerClient: LYRClient!
	
	@IBOutlet weak var resultsTable: UITableView!
	
	var firstName = ""
	var lastName = ""
	var sports = ""
	var position = ""
	var school = ""
	var region = ""
	var phone = ""
	
	var keyboardSize:CGFloat = 0.0
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)

		self.retrieveInfo()
		

		
		
		//keyboard notification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
		
		
//		let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
//		tapScrollViewGesture.numberOfTapsRequired = 1
//		resultsScrollView.addGestureRecognizer(tapScrollViewGesture)
//		
//		let tapScrollViewGesture2 = UITapGestureRecognizer(target: self, action: "addBtn_click")
//		tapScrollViewGesture2.numberOfTapsRequired = 1
//		addBtn.addGestureRecognizer(tapScrollViewGesture2)

        // Do any additional setup after loading the view.
    }
	
	
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		let pointInView:CGPoint = textField.superview!.convertPoint(textField.frame.origin, toView:self.view)
		

		if keyboardSize != 0.0 {
			if keyboardSize < pointInView.y {

//				var contentOffset:CGPoint = self.resultsTable.contentOffset
//				contentOffset.y  = pointInTable.y
				
//				if let accessoryView = textField.inputAccessoryView {
//					contentOffset.y -= accessoryView.frame.size.height
//				}
				self.resultsTable.contentOffset.y += (pointInView.y - keyboardSize)
			}
		}
		return true;
	}
	
	
	func keyboardWasShown(notification:NSNotification) {
		
		let dict:NSDictionary = notification.userInfo!
		let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let rect:CGRect = s.CGRectValue()
		
		keyboardSize = rect.origin.y - 50
		

		
		UIView.animateWithDuration(0.01, animations: {
			
			
			
			}, completion: {
				(finished:Bool) in
				
				
		})
		
	}
	
	func keyboardWillHide(notification:NSNotification) {
		
		
		let dict:NSDictionary = notification.userInfo!
		let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let rect:CGRect = s.CGRectValue()
		
		
//		self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY
//		self.resultsScrollView.frame.size.height = self.scrollViewOriginalHeight
//		self.resultsScrollView.contentSize.height = self.scrollViewOriginalContentSize
//		
//		self.viewBottomConst.constant = 0
//		
//		
//		var bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
//		self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
		
		
		
		
		
	}

	
	
	
	
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.view.endEditing(true)
	}

	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! profileCell
		
		cell.selectionStyle = UITableViewCellSelectionStyle.None

		
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				if firstName != "" {
					cell.textField.text = firstName
				} else {
					cell.textField.placeholder = "First Name (Required)"
				}
			}
			if indexPath.row == 1 {
				if lastName != "" {
					cell.textField.text = lastName
				} else {
					cell.textField.placeholder = "Last Name (Required)"
				}
			}
		}
		if indexPath.section == 1 {
			if indexPath.row == 0 {
				if sports != "" {
					cell.textField.text = sports
				} else {
					cell.textField.placeholder = "Sports (Optional)"
				}
			}
			if indexPath.row == 1 {
				if position != "" {
					cell.textField.text = position
				} else {
					cell.textField.placeholder = "Position (Optional)"
				}
			}
		}
		if indexPath.section == 2 {
			if indexPath.row == 0 {
				if school != "" {
					cell.textField.text = school
				} else {
					cell.textField.placeholder = "School (Optional)"
				}
			}
			if indexPath.row == 1 {
				if region != "" {
					cell.textField.text = region
				} else {
					cell.textField.placeholder = "Region (Optional)"
				}
			}
		}
		if indexPath.section == 3 {
			if indexPath.row == 0 {
				if phone != "" {
					cell.textField.text = phone
				} else {
					cell.textField.placeholder = "Phone Number (Optional)"
				}
			}
		}
		
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 2
		}
		if section == 1 {
			return 2
		}
		if section == 2 {
			return 2
		}
		else {
			return 1
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 4
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func retrieveInfo() {
		
		let currentUser = PFUser.currentUser()
		
		if let currentUser = currentUser {
			
			if let getFirstName = currentUser.objectForKey("firstName") as? String {
				firstName = getFirstName
			}
			if let getLastName = currentUser.objectForKey("lastName") as? String {
				lastName = getLastName
			}
			if let getSports = currentUser.objectForKey("Sports") as? String {
				sports = getSports
			}
			if let getPosition = currentUser.objectForKey("Position") as? String {
				position = getPosition
			}
			if let getSchool = currentUser.objectForKey("School") as? String {
				school = getSchool
			}
			if let getRegion = currentUser.objectForKey("Region") as? String {
				region = getRegion
			}
			if let getPhone = currentUser.objectForKey("phone") as? String {
				phone = getPhone
			}
		}
		
		if firstName == "" {
			addCancelBtn()
		}
		
		self.resultsTable.reloadData()
	}
	
	func addCancelBtn() {
		let title = NSLocalizedString("Cancel",  comment: "")
		let cancelItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleCancelTap"))
		cancelItem.tintColor = UIColor.whiteColor()
		self.navigationItem.leftBarButtonItem = cancelItem
	}
	
	func handleCancelTap() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func saveBtn_click(sender: AnyObject) {
		
		let currentUser = PFUser.currentUser()
		
		let firstNameCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! profileCell
		
		if firstNameCell.textField.text != "" {
			firstName = firstNameCell.textField.text!
		}
		
		let lastNameCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! profileCell
		
		if lastNameCell.textField.text != "" {
			lastName = lastNameCell.textField.text!
		}
		
		let sportsCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! profileCell
		
		if sportsCell.textField.text != "" {
			sports = sportsCell.textField.text!
		}
		
		let positionCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! profileCell
		
		if positionCell.textField.text != "" {
			position = positionCell.textField.text!
		}
		
		let schoolCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! profileCell
		
		if schoolCell.textField.text != "" {
			school = schoolCell.textField.text!
		}
		
		let regionCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2)) as! profileCell
		
		if regionCell.textField.text != "" {
			region = regionCell.textField.text!
		}
		
		let phoneCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as! profileCell
		
		if phoneCell.textField.text != "" {
			phone = phoneCell.textField.text!
		}

		
		
		
		if firstName == "" || lastName == "" {
			
			let infoAlert = UIAlertController(title: "Notification", message: "Please fill out the required fields", preferredStyle: UIAlertControllerStyle.Alert)
			
			
			infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
				
			}))
			
			self.presentViewController(infoAlert, animated: true, completion: nil)

		} else {
			
			if let currentUser = currentUser {
				
				currentUser["firstName"] = firstName
				currentUser["lastName"] = lastName
				currentUser["Sports"] = sports
				currentUser["Position"] = position
				currentUser["School"] = school
				currentUser["Region"] = region
				currentUser["phone"] = phone
				
				if isSignUp {
					currentUser["notification"] = "0"
				}
				currentUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
					
					if error == nil {
						print("saved")
						
						if isSignUp {
							
							let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
							
							let controller = storyboard.instantiateViewControllerWithIdentifier("GroupVC") as! GroupVC
							controller.layerClient = self.layerClient
							
							self.navigationController?.pushViewController(controller, animated: true)
							//						self.presentViewController(nav, animated: true, completion: nil)
							
						} else {
							self.dismissViewControllerAnimated(true, completion: nil)
						}
					}
				})
			}
		}
	}
	
//	public override func supportedInterfaceOrientations() -> Int {
//		return UIInterfaceOrientation.Portrait.rawValue
//	}
//	
//	public override func shouldAutorotate() -> Bool {
//		return false
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

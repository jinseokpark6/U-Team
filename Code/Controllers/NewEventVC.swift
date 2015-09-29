//
//  NewEventVC.swift
//  UniversiTeam2
//
//  Created by Jin Seok Park on 2015. 7. 6..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit


var isEditing = false


class NewEventVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, ATLParticipantTableViewControllerDelegate {

	@IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var resultsTable: UITableView!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var pickerView: UIView!
	@IBOutlet weak var pickerSubView: UIPickerView!
	
	
	@IBOutlet weak var resultsTableTopConstraint: NSLayoutConstraint!
	
	
	
    var eventDescription = ""
	var eventLocation = ""
    var cellArray = [newEventCell]()
    var firstIndexPath = NSIndexPath()
    var eventTitle = String()
	var participants = [String]()
	
	var startDate = NSDate()
	var endDate = NSDate()
	var selectedDate = ""
	
	var repeatLabel = ""
	
	let pickerData = ["None","Daily","Weekly","Monthly"]

	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.hidesBottomBarWhenPushed = true
		

		
		
		
		
		if isEditing {
			self.title = "Edit Event"
			self.addBtn.title = "Save"
//			self.navigationItem.hidesBackButton = true
		} else {
			self.title = "Add Event"
			self.addBtn.title = "Add"
		}

        // Do any additional setup after loading the view.
    }
	
	func didTapNoteField() {
		
		self.resultsTable.frame.origin.y -= 200
	
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.view.endEditing(true)
		if self.pickerView.hidden == false {
			self.pickerView.hidden = true
		}
	}
	
//	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//		println("qwer")
//		self.view.endEditing(true)
//		if self.pickerView.hidden == false {
//			self.pickerView.hidden = true
//		}
//	}
	
	override func viewDidAppear(animated: Bool) {
		
		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)

		
		self.pickerView.hidden = true
		

		
		components.year = year
		components.month = month
		components.day = day
		
		
		println("COMPONENTS: \(components)")
		
		if !isEditing {
			components.minute = components.minute - (components.minute % 5)
			
			var date = NSCalendar.currentCalendar().dateFromComponents(components)
			
			startDate = (NSCalendar.currentCalendar().dateFromComponents(components))!
			components.hour += 1
			endDate = (NSCalendar.currentCalendar().dateFromComponents(components))!
			
			repeatLabel = "None"
			
		} else {
			startDate = selectedEvent[0].objectForKey("startTime") as! NSDate
			endDate = selectedEvent[0].objectForKey("endTime") as! NSDate
			
			repeatLabel = selectedEvent[0].objectForKey("Repeat") as! String

		}

		
		
		self.datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
		
		
		self.resultsTable.reloadData()

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		self.repeatLabel = pickerData[row]
		
		self.resultsTable.reloadData()
		println("YESSS")
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		return pickerData[row]
	}
	
	
	
	
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.section == 3 && indexPath.row == 0 {
			return UITableViewAutomaticDimension
		} else {
			return 45
		}
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:newEventCell = resultsTable.dequeueReusableCellWithIdentifier("Cell") as! newEventCell
        
        
        resultsTable.cellForRowAtIndexPath(indexPath)
        
        println(indexPath)
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
				if selectedEvent.count != 0 {
					if let title = selectedEvent[0].objectForKey("Title") as? String {
						if title == "" {
							cell.textField.placeholder = "Title"
						} else {
							cell.textField.text = title
						}
					} else {
						cell.textField.placeholder = "Title"
					}
				} else {
					cell.textField.placeholder = "Title"
				}

                eventDescription = cell.placeholder.text
                firstIndexPath = indexPath
            }
            if (indexPath.row == 1) {
				if selectedEvent.count != 0 {
					if let title = selectedEvent[0].objectForKey("Location") as? String {
						if title == "" {
							cell.textField.placeholder = "Location"
						} else {
							cell.textField.text = title
						}
					} else {
						cell.textField.placeholder = "Location"
					}
				} else {
					cell.textField.placeholder = "Location"
				}
				
				
            }
        }
		
		//start and end DATES
		var dateFormatter = NSDateFormatter()
		
		dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
		
		if (indexPath.section == 1) {
			
			cell.textField.hidden = true
			
			if indexPath.row == 0 {
				cell.textLabel?.text = "Start"
				cell.placeholder.text = dateFormatter.stringFromDate(startDate)
			}
			if indexPath.row == 1 {
				cell.textLabel?.text = "End"
				cell.placeholder.text = dateFormatter.stringFromDate(endDate)
			}
			if indexPath.row == 2 {
				cell.textLabel?.text = "Repeat"
				cell.placeholder.text = repeatLabel
			}
		}

		
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
				
				cell.textField.text = "Participants"
				cell.textField.userInteractionEnabled = false
				
				var nameLabel = ""
				
				for var i=0; i<eventParticipantArray.count; i++ {
					
					if i != eventParticipantArray.count - 1 {
						nameLabel += eventParticipantArray[i]?.objectForKey("firstName") as! String + ", "
					} else {
						nameLabel += eventParticipantArray[i]?.objectForKey("firstName") as! String
					}
				}
				
                cell.placeholder.placeholder = nameLabel

				
				var detailButton = UITableViewCellAccessoryType.DisclosureIndicator
				cell.accessoryType = detailButton
				
            }
        }
		
		
		if indexPath.section == 3 {

			var detailButton = UITableViewCellAccessoryType.DisclosureIndicator
			cell.accessoryType = detailButton

			
//			cell.placeholder.hidden = true
			
			cell.textField.userInteractionEnabled = false
			cell.textField.text = "Notes"
			
			if indexPath.row == 0 {
				if selectedEvent.count != 0 {
					if let note = selectedEvent[0].objectForKey("Description") as? String {
						if note == "" {
							cell.placeholder.text = ""
						} else {
							cell.placeholder.text = note
						}
					} else {
						cell.placeholder.text = ""
					}
				}
				
				
				else {
					if noteText == "" {
						cell.textField.text = "Notes"
					}
					else {
						cell.placeholder.text = noteText
						noteText == ""
					}
				}
			}
		}
		
		if indexPath.section == 4 {
			
			cell.textField.hidden = true
			
			cell.textLabel?.textColor = UIColor.redColor()
			cell.textLabel?.text = "Delete Event"
			
		}
		

        return cell
    }
	
    func updateSwitch(mySwitch: UISwitch) {
        
        if mySwitch.on {
            mySwitch.setOn(true, animated:true)
        } else {
            mySwitch.setOn(false, animated:true)
        }
    }
	

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath newIndexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
		
		var cell = tableView.cellForRowAtIndexPath(newIndexPath) as! newEventCell
		
		
		if newIndexPath.section == 0 {
			
			cell.textField.becomeFirstResponder()
		}
		
		
		if newIndexPath.section == 1 {
			
			self.view.endEditing(true)
			
			if newIndexPath.row == 2 {
				//				self.pickerSubView.hidden = false
				//				self.datePicker.hidden = true
				self.comingSoon()
			} else {
				if self.pickerView.hidden == false {
					self.pickerView.hidden = true
				} else {
					self.pickerView.hidden = false
				}
				
				if newIndexPath.row == 0 {
					self.datePicker.setDate(startDate, animated: true)
					self.pickerSubView.hidden = true
					self.datePicker.hidden = false
				}
				if newIndexPath.row == 1 {
					self.datePicker.setDate(endDate, animated: true)
					self.pickerSubView.hidden = true
					self.datePicker.hidden = false
				}
				
				if newIndexPath.row == 0 {
					self.selectedDate = "start"
				} else {
					self.selectedDate = "end"
				}
			}
			
		}

		
		if newIndexPath.section == 2 {
			
			isEvent = true
			isAllUsers = true
			allTeamMemberArray.removeAll(keepCapacity: false)
			
			var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("ConversationDetailVC") as! ConversationDetailVC

			self.navigationController?.pushViewController(controller, animated: true)
			
		}
		
		if newIndexPath.section == 3 {

			var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			var controller = storyboard.instantiateViewControllerWithIdentifier("NoteVC") as! NoteVC
			
			
			noteText = cell.placeholder.text
			
			self.navigationController!.pushViewController(controller, animated: true)

			
			
		}
		
		if newIndexPath.section == 4 {
			if newIndexPath.row == 0 {
				
				showAlert()
			}
		}
    }

	func datePickerChanged(datePicker:UIDatePicker) {
		
		if self.selectedDate == "start" {
			
			startDate = datePicker.date

			var components = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: datePicker.date)

			components.hour += 1
			
			endDate = NSCalendar.currentCalendar().dateFromComponents(components)!
			
		} else {
//			datePicker.date.
			endDate = datePicker.date
			
		}
		
		self.resultsTable.reloadData()

	}
	
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return ""
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {return 2}
        if section==1 {return 3}
        if section==2 {return 1}
		if section==3 {return 1}
		if section==4 {return 1}
        else {return 0}
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		if isEditing {
			return 4
		} else {
			return 4
		}
    }

    @IBAction func cancelBtn_click(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
		
    }
    
    @IBAction func addBtn_click(sender: AnyObject) {
		
		
		
		//update year, month, day variables
		
		self.updateInfo()
		
		
		
		var infoAlert = UIAlertController(title: "Notification", message: "Do you want to notify players of this event?", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			
			var teamName = selectedTeamObject[0].objectForKey("name") as! String
			
			
			for var i=0; i<eventParticipantIdArray.count; i++ {
				
				var uQuery:PFQuery = PFUser.query()!
				
				uQuery.whereKey("objectId", equalTo: eventParticipantIdArray[i])
				
				
				var pushQuery:PFQuery = PFInstallation.query()!
				pushQuery.whereKey("user", matchesQuery: uQuery)
				
				var startDate = selectedEvent[0].objectForKey("startTime") as! NSDate
				
				var dateFormatter = NSDateFormatter()
				
				dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
				
				var date = dateFormatter.stringFromDate(startDate)
				
				
				var data = ["alert" : "\(selectedTeamName) Schedule Notification for \(date)" ,"sound" : "notification_sound.caf"]
				
				var push:PFPush = PFPush()
				push.setQuery(pushQuery)
				push.setData(data)
				
				push.sendPushInBackgroundWithBlock({
					(success: Bool, error: NSError?) -> Void in
					
					if (error == nil) {
						println("push sent")
						
					} else {
						
						println("Error sending push: \(error!.description).");
						
					}
				})
			}
			
			needReload = true
			self.dismissViewControllerAnimated(true, completion: nil)
			
		}))
		
		infoAlert.addAction(UIAlertAction(title: "Skip", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			needReload = true
			self.dismissViewControllerAnimated(true, completion: nil)
			
		}))

		
		
		if !isEditing {
			
			
			var calendarDBTable = PFObject(className: "Schedule")
			calendarDBTable["Year"] = year
			calendarDBTable["Month"] = month
			calendarDBTable["Day"] = day
			calendarDBTable["Title"] = eventTitle
			calendarDBTable["Description"] = eventDescription
			calendarDBTable["Participants"] = eventParticipantIdArray
			
			calendarDBTable["startTime"] = startDate
			calendarDBTable["endTime"] = endDate
			
			calendarDBTable["Repeat"] = repeatLabel
			calendarDBTable["teamId"] = selectedTeamId
			
			var postACL = PFACL()
			postACL.setPublicReadAccess(true)
			postACL.setPublicWriteAccess(true)
			calendarDBTable.ACL = postACL

			
			
			
			println("START DATE: \(startDate)")
			println("END DATE: \(endDate)")
			
			
			println(eventDescription)
			
			calendarDBTable.saveInBackgroundWithBlock {
				(success:Bool, error:NSError?) -> Void in
				
				if success == true {
					
					println("event saved")
					
					var currentUser = PFUser.currentUser()
					
					var firstName = currentUser?.objectForKey("firstName") as! String
					var lastName = currentUser?.objectForKey("lastName") as! String

					
					var dateFormatter = NSDateFormatter()
					dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
					dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
					var date = dateFormatter.stringFromDate(self.startDate)
					
					var announcement = PFObject(className: "Team_Announcement")
					announcement["name"] = "\(firstName) \(lastName)"
					announcement["userId"] = PFUser.currentUser()!.objectId
					announcement["type"] = "Add Event"
					announcement["title"] = self.eventTitle
					announcement["date"] = self.startDate
					announcement["eventId"] = calendarDBTable.objectId!
					announcement["teamId"] = selectedTeamId


					
					announcement.saveInBackgroundWithBlock({ (success, error) -> Void in
						
						if eventParticipantIdArray.count != 0 {
							
							self.presentViewController(infoAlert, animated: true, completion: nil)

						} else {
							self.dismissViewControllerAnimated(true, completion: nil)
						}
					})
					
				}
			}

			
		} else {
			


			
			
			var query = PFQuery(className:"Schedule")
			println("EVENT: \(selectedEvent)")
			query.whereKey("objectId", equalTo: selectedEvent[0].objectId!)
				query.getFirstObjectInBackgroundWithBlock({ (pfObject, error) -> Void in
				
				if error == nil {
					pfObject!["Year"] = year
					pfObject!["Month"] = month
					pfObject!["Day"] = day
					
					pfObject!["startTime"] = self.startDate
					pfObject!["endTime"] = self.endDate
					pfObject!["Location"] = self.eventLocation
					pfObject!["Description"] = self.eventDescription
					pfObject!["Repeat"] = self.repeatLabel

					if self.eventTitle == "" {
						self.eventTitle = "New Event"
					}

					pfObject!["Title"] = self.eventTitle
					pfObject!["Participants"] = eventParticipantIdArray
					pfObject!["teamId"] = selectedTeamId

					
					pfObject!.saveInBackgroundWithBlock {
						(success:Bool, error:NSError?) -> Void in

						var currentUser = PFUser.currentUser()
						
						var firstName = currentUser?.objectForKey("firstName") as! String
						var lastName = currentUser?.objectForKey("lastName") as! String
						
						
						var dateFormatter = NSDateFormatter()
						dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
						dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
						var date = dateFormatter.stringFromDate(self.startDate)
						
						var announcement = PFObject(className: "Team_Announcement")
						announcement["name"] = "\(firstName) \(lastName)"
						announcement["userId"] = PFUser.currentUser()!.objectId
						announcement["type"] = "Update Event"
						announcement["title"] = self.eventTitle
						announcement["date"] = self.startDate
						announcement["eventId"] = selectedEvent[0].objectId!
						announcement["teamId"] = selectedTeamId
						
						announcement.saveInBackgroundWithBlock({ (success, error) -> Void in
							
							self.presentViewController(infoAlert, animated: true, completion: nil)
						})
					}
					
				}
			})

			
			

			
			
		}
		
    }
	
//	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//		
//		self.view.endEditing(true)
//	}
	
//	func textFieldDidBeginEditing(textField: UITextField) {
//		
//		self.resultsTable.frame.origin.y -= 100
//	}
//
//	func textFieldDidEndEditing(textField: UITextField) {
//		
//		
//	}
	

	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		return true
	}
	
	
	
	func showAlert() {
		

	}
	
	
	
	// MARK - ATLParticipantTableViewController Delegate Methods
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
		println("participant: \(participant)")
//		self.addressBarController.selectParticipant(participant)
//		println("selectedParticipants: \(self.addressBarController.selectedParticipants)")
		//        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSearchWithString searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
		UserManager.sharedManager.queryTeamForUserWithName(searchText, teamId:selectedTeamId) { (participants, error) in
			if (error == nil) {
				if let callback = completion {
					callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
				}
			} else {
				println("Error search for participants: \(error)")
			}
		}
	}
	
	
	func updateInfo() {
		
		
		let startComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: startDate)

		let endComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: endDate)

		year = startComponents.year
		month = startComponents.month
		day = startComponents.day
		
		var titleCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! newEventCell
		
		if titleCell.textField.text != "" {
			eventTitle = titleCell.textField.text
		} else {
			eventTitle = ""
		}
		
		var locationCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! newEventCell
		
		println("LOCATION: \(locationCell.textField.text)")
		if locationCell.textField.text != "" {
			eventLocation = locationCell.textField.text
		} else {
			eventLocation = ""
		}
		println("asdf")
		
		var noteCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) as! newEventCell
		
		if noteCell.textField.text != "" {
			eventDescription = noteCell.textField.text
		} else {
			eventDescription = ""
		}
		println("asdf1")

		var repeatCell = self.resultsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) as! newEventCell
		
		if repeatCell.textField.text != "" {
			repeatLabel = repeatCell.placeholder.text
		} else {
			repeatLabel = ""
		}
		println("asdf2")

	}
	
	func comingSoon() {
		
		var infoAlert = UIAlertController(title: "Notification", message: "Coming Soon", preferredStyle: UIAlertControllerStyle.Alert)
		
		println("INTERFACE: \(infoAlert.supportedInterfaceOrientations())")
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			
		}))
		
		
		self.presentViewController(infoAlert, animated: true, completion: nil)
		
		
	}

	

	internal override func supportedInterfaceOrientations() -> Int {
		return UIInterfaceOrientation.Portrait.rawValue
	}
	
	internal override func shouldAutorotate() -> Bool {
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

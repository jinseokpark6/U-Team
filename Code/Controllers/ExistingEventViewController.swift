//
//  ExistingEventViewController.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 8. 27..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

var needReload = false

class ExistingEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var resultsTable: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		

		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)
		
//		if status == "Coach" {
			let title = NSLocalizedString("Edit", comment: "")
			let detailsItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonTapped"))
			self.navigationItem.setRightBarButtonItem(detailsItem, animated: false)

//		}
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		
		if needReload {
			let query = PFQuery(className:"Schedule")
			query.whereKey("objectId", equalTo:selectedEvent[0].objectId!)
			query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
				
				if error == nil {
					selectedEvent.removeAll(keepCapacity: false)
					selectedEvent.append(object!)
					self.resultsTable.reloadData()
				}
			}
		}
	}
	
	func editButtonTapped() {
		
		isEditing = true
		
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("NewEventVC") as! NewEventVC
		let nav: UINavigationController = UINavigationController()
		nav.addChildViewController(controller)
		
		self.presentViewController(nav, animated: true, completion: nil)

	}
	
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.section == 0 {
			return 175
		}
		if indexPath.section == 1 {
			return 50
		}
		if indexPath.section == 2 {
			return UITableViewAutomaticDimension
		}
		else {
			return 30
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 1
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		if status == "Coach" {
			return 6
//		}
//		if status == "Player" {
//			return 4
//		}
//		else {
//			return 1
//		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return ""
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! existingEventCell

		if indexPath.section == 0 {
			cell.titleLabel.text = selectedEvent[0].objectForKey("Title") as? String
			
			let startDate = selectedEvent[0].objectForKey("startTime") as! NSDate
			let endDate = selectedEvent[0].objectForKey("endTime") as! NSDate
			
			let dateFormatter1 = NSDateFormatter()
			let dateFormatter2 = NSDateFormatter()
			
			dateFormatter1.dateStyle = NSDateFormatterStyle.MediumStyle
			dateFormatter2.timeStyle = NSDateFormatterStyle.ShortStyle

			let date1 = dateFormatter1.stringFromDate(startDate)
			let date2 = dateFormatter1.stringFromDate(endDate)
			let startTime = dateFormatter2.stringFromDate(startDate)
			let endTime = dateFormatter2.stringFromDate(endDate)
			
			if date1 == date2 {
				cell.dateLabel.text = "\(date1)"
			} else {
				cell.dateLabel.text = "\(date1) to \(date2)"
			}
			cell.timeLabel.text = "\(startTime) to \(endTime)"
			
			cell.selectionStyle = UITableViewCellSelectionStyle.None;

		}
		

		if indexPath.section == 1 {
			if let location = selectedEvent[0].objectForKey("Location") as? String {
				cell.textLabel!.text = "Location"
				cell.locationLabel.text = "\(location)"
			} else {
				cell.textLabel!.text = "Location"
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyle.None;

		}
		

		
		if indexPath.section == 2 {
			
			if let note = selectedEvent[0].objectForKey("Description") as? String {
				
				cell.titleLabel.text = "Notes"
				cell.dateLabel.text = "\(note)"
			} else {
				cell.textLabel!.text = "Notes"
			}
		}
		

		
		if indexPath.section == 3 {
			
			cell.titleLabel.text = "Participants"

			
			var nameLabel = ""

			if let participants = selectedEvent[0].objectForKey("Participants") as? [String] {

				if eventParticipantArray.count != 0 {
					eventParticipantIdArray.removeAll(keepCapacity: false)
					eventParticipantArray.removeAll(keepCapacity: false)
				}
				
				eventParticipantIdArray = participants

				for var i=0; i<eventParticipantIdArray.count; i++ {
					
					let query = PFUser.query()
					let object = query?.getObjectWithId(eventParticipantIdArray[i]) as? PFUser
					eventParticipantArray.append(object)
					
				}
				
				for var i=0; i<eventParticipantArray.count; i++ {
				
					if i != eventParticipantArray.count - 1 {

						nameLabel += eventParticipantArray[i]?.objectForKey("firstName") as! String + ", "

					} else {

						nameLabel += eventParticipantArray[i]?.objectForKey("firstName") as! String

					}
				}

			}
			
			
			

			cell.dateLabel.text = nameLabel

		}
		

		
		if indexPath.section == 4 {
			
			cell.textLabel?.textAlignment = NSTextAlignment.Center
			cell.textLabel!.text = "Notify Participants"
			cell.textLabel?.textColor = UIColor.blueColor()
		}
		
		if indexPath.section == 5 {
			
			cell.textLabel?.textAlignment = NSTextAlignment.Center
			cell.textLabel!.text = "Delete Event"
			cell.textLabel?.textColor = UIColor.redColor()
		}

	
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == 2 {

			
//			if status == "Coach" {
//				
//			}
//			
//			if status == "Player" {
				let infoAlert = UIAlertController(title: "Add Notes", message: "Please Type Notes", preferredStyle: UIAlertControllerStyle.Alert)
				
				infoAlert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
					
					textField.placeholder = "Notes"
				}
				
				infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
					

					let noteTF = infoAlert.textFields?.first
                    if let noteTF = noteTF {
                        let note = noteTF.text

                        
                        if note != "" {
                            let query = PFQuery(className:"Schedule")
                            
                            print(selectedEvent[0].objectId!)
                            query.getObjectInBackgroundWithId(selectedEvent[0].objectId!, block: { (pfObject, error) -> Void in
                                
                                print("object: \(pfObject)")
                                if error == nil {
                                    
                                    let currentUser = PFUser.currentUser()
                                    let first = currentUser?.objectForKey("firstName") as! String
                                    let last = currentUser?.objectForKey("lastName") as! String
                                    
                                    
                                    if let oldNote = pfObject!.objectForKey("Description") as? String {
                                        
                                        
                                        let newNote = "\(oldNote)" + "\r\n" + "\(first) \(last) - \(note)"
                                        
                                        pfObject!["Description"] = newNote
                                        
                                    } else {
                                        
                                        pfObject!["Description"] = note
                                    }
                                    
                                    pfObject!.saveInBackgroundWithBlock {
                                        (success:Bool, error:NSError?) -> Void in
                                        
                                        if error == nil {
                                            
                                            let currentUser = PFUser.currentUser()
                                            
                                            let firstName = currentUser?.objectForKey("firstName") as! String
                                            let lastName = currentUser?.objectForKey("lastName") as! String
                                            
                                            let title = selectedEvent[0].objectForKey("Title") as! String
                                            
                                            let date = selectedEvent[0].createdAt!
                                            
                                            
                                            let announcement = PFObject(className: "Team_Announcement")
                                            announcement["name"] = "\(firstName) \(lastName)"
                                            announcement["type"] = "Add Note"
                                            announcement["title"] = title
                                            announcement["date"] = date
                                            announcement["eventId"] = selectedEvent[0].objectId!
                                            announcement["teamId"] = selectedTeamId
                                            
                                            
                                            
                                            announcement.saveInBackgroundWithBlock({ (success, error) -> Void in
                                                
                                                if error == nil {
                                                    self.resultsTable.reloadData()
                                                }
                                            })
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
				}))
				
				infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
					
					
				}))
				
				self.presentViewController(infoAlert, animated: true, completion: nil)
//			}

		}
		if indexPath.section == 3 {
			
			isEvent = true
			isAllUsers = false
			eventParticipantArray.removeAll(keepCapacity: false)
			
			
			let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("ConversationDetailVC") as! ConversationDetailVC
			
			
			self.navigationController?.pushViewController(controller, animated: true)
			

		}
		
		if indexPath.section == 4 {
			
				let infoAlert = UIAlertController(title: "Notification", message: "Do you want to notify players of this event?", preferredStyle: UIAlertControllerStyle.Alert)
				
				
				infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
					
					
					let teamName = selectedTeamObject[0].objectForKey("name") as! String
					
					print("PARTICIPANTS: \(eventParticipantIdArray)")
					
					for var i=0; i<eventParticipantIdArray.count; i++ {
						
						let uQuery:PFQuery = PFUser.query()!
						
						uQuery.whereKey("objectId", equalTo: eventParticipantIdArray[i])
						
						
						let pushQuery:PFQuery = PFInstallation.query()!
						pushQuery.whereKey("user", matchesQuery: uQuery)
						
						
						let startDate = selectedEvent[0].objectForKey("startTime") as! NSDate
						
						let dateFormatter = NSDateFormatter()
						
						dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
						
						let date = dateFormatter.stringFromDate(startDate)

						
						let data = ["alert" : "\(selectedTeamName) Schedule Notification for \(date)" ,"sound" : "notification_sound.caf"]
						
						let push:PFPush = PFPush()
						push.setQuery(pushQuery)
						push.setData(data)
						
						push.sendPushInBackgroundWithBlock({
							(success: Bool, error: NSError?) -> Void in
							
							if (error == nil) {
								print("push sent")
								
							} else {
								
								print("Error sending push: \(error!.description).");
								
							}
						})
					}
					
					
				}))
				
				infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
					
					
				}))
				
				self.presentViewController(infoAlert, animated: true, completion: nil)
				

		}

		if indexPath.section == 5 {
			
			
			let infoAlert = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.Alert)
			
			
			infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
				
				let query = PFQuery(className:"Schedule")
				query.whereKey("objectId", equalTo: selectedEvent[0].objectId!)
				query.whereKey("teamId", equalTo: selectedTeamId)
				query.getFirstObjectInBackgroundWithBlock({ (object:PFObject?, error:NSError?) -> Void in
					
					object!.delete()
					print("deleted")
					
					self.dismissViewControllerAnimated(true, completion: nil)
					
					
				})
			}))
			
			infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
				
				
			}))
			
			self.presentViewController(infoAlert, animated: true, completion: nil)
			
			
		}

		
	}
	
	@IBAction func cancelBtn_click(sender: AnyObject) {
		
		noteText = ""
		self.dismissViewControllerAnimated(true, completion: nil)
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

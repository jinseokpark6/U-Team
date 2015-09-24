//
//  ConversationDetailVC.swift
//  UniversiTeam2
//
//  Created by Jin Seok Park on 2015. 8. 8..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

var index = 0

var teamRoomPlayerNames = [String]()

var participantArray = [PFUser?]()
var eventParticipantIdArray = [String]()
var eventParticipantArray = [PFUser?]()
var allTeamMemberArray = [PFUser?]()

var isEvent = false
var isAllUsers = false

class ConversationDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ATLParticipantTableViewControllerDelegate {

//	@IBOutlet weak var photoView: UIImageView!
	@IBOutlet weak var resultsTable: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		println("PART: \(participantArray)")
		if isEvent {
			
			self.title = "Event Participants"

			if isAllUsers {
				
				if isEditing {
//					let title = NSLocalizedString("Save",  comment: "")
//					var saveItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleSaveTap"))
//					saveItem.tintColor = UIColor.whiteColor()
//					self.navigationItem.rightBarButtonItem = saveItem
				}
			}
		} else {
			self.title = "Chat Room"
			
			
		}
		
		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)

		
//		self.fetchInfo()
		
		println("PART: \(participantArray)")
		
		
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool) {
		
		self.fetchInfo()
	}
	
	func handleSaveTap() {
		
		var query = PFQuery(className:"Schedule")
		var pfObject = query.getObjectWithId(selectedEvent[0].objectId!)
		pfObject?.setObject(eventParticipantIdArray, forKey: "Participants")
		pfObject?.saveInBackgroundWithBlock({ (success, error) -> Void in
			
			if error == nil {
				println("success")
			}
		})
	}
	
	func fetchInfo() {
		
		if isEvent {
			
			
			UserManager.sharedManager.queryForTeamUsersWithCompletion(selectedTeamId, includeCurrUser: true) { (users: NSArray?, error: NSError?) in
				if error == nil {
					let participants = NSSet(array: users as! [PFUser]) as! Set<PFUser>
					println("PARTIDIFOSDINV: \(participants)")
					for participant in participants {
						allTeamMemberArray.append(participant)
					}
					println("14")
					
					self.resultsTable.reloadData()
					println(allTeamMemberArray)
				} else {
					println("Error querying for All Users: \(error)")
				}
			}
			
			
			if isAllUsers {
				
			}
				
			else {

				
				
				
				if let participants = selectedEvent[0].objectForKey("Participants") as? [String] {
					eventParticipantIdArray = participants
				} else {
					eventParticipantIdArray = []
				}
				println("2")
				
				var query = PFUser.query()
				query?.whereKey("objectId", containedIn: eventParticipantIdArray)
				query?.addAscendingOrder("firstName")
				query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
					
					if error == nil {
						for user: PFUser in (objects as! [PFUser]) {
							eventParticipantArray.append(user)
						}
						self.resultsTable.reloadData()
						println(eventParticipantArray)
					}
				})
				println("3")
				
			}
		}
	}
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! conversationCell
		
		if cell.nameLabel.text == "" {
			
			if !isEvent {
				
				//		if indexPath.row == 0 {
				//			cell.textLabel!.text = "+ Add People"
				//			cell.textLabel?.textColor = UIColor.redColor()
				//		} else {
				
				var currentUser = ""
				if participantArray[indexPath.row]!.objectId! == PFUser.currentUser()!.objectId {
					currentUser = "(me)"
				}
				
				var firstName = participantArray[indexPath.row]?.objectForKey("firstName") as! String
				var lastName = participantArray[indexPath.row]?.objectForKey("lastName") as! String
				
				cell.nameLabel.text = "\(firstName) \(lastName) \(currentUser)"
				cell.profileIdLabel.text = participantArray[indexPath.row]?.objectId
				
				if let file = participantArray[indexPath.row]?.objectForKey("photo") as? PFFile {
					var data = file.getData()
					var image = UIImage(data: data!)
					cell.profileImg.image = image
				}
				//		}
			}
			
			if isEvent {
				if isAllUsers {
					
					var firstName = allTeamMemberArray[indexPath.row]?.objectForKey("firstName") as! String
					var lastName = allTeamMemberArray[indexPath.row]?.objectForKey("lastName") as! String
					
					cell.nameLabel.text = "\(firstName) \(lastName)"
					cell.profileIdLabel.text = allTeamMemberArray[indexPath.row]?.objectId
					
					if let file = allTeamMemberArray[indexPath.row]?.objectForKey("photo") as? PFFile {
						var data = file.getData()
						var image = UIImage(data: data!)
						cell.profileImg.image = image
					}
					println("1 \(eventParticipantArray)")
					for var i=0; i<eventParticipantArray.count; i++ {
						println("2 \(cell.profileIdLabel.text)")

						if cell.profileIdLabel.text == eventParticipantArray[i]?.objectId {
							println("3")

							cell.accessoryType = UITableViewCellAccessoryType.Checkmark
						}
					}
					
				} else {
					
					var firstName = eventParticipantArray[indexPath.row]?.objectForKey("firstName") as! String
					var lastName = eventParticipantArray[indexPath.row]?.objectForKey("lastName") as! String
					
					cell.nameLabel.text = "\(firstName) \(lastName)"
					cell.profileIdLabel.text = eventParticipantArray[indexPath.row]?.objectId
					
					if let file = eventParticipantArray[indexPath.row]?.objectForKey("photo") as? PFFile {
						var data = file.getData()
						var image = UIImage(data: data!)
						cell.profileImg.image = image
					}
					
				}
			}
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		
//		if indexPath.row == 0 {
//
//		
//			UserManager.sharedManager.queryForTeamUsersWithCompletion(selectedTeamId) { (users: NSArray?, error: NSError?) in
//				if error == nil {
//					let participants = NSSet(array: users as! [PFUser]) as Set<NSObject>
//					let controller = ParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
//					controller.delegate = self
//					isModal = false
//					self.navigationController!.pushViewController(controller, animated: true)
//				} else {
//					println("Error querying for All Users: \(error)")
//				}
//			}
//		
//		} else {
		
			var cell = tableView.cellForRowAtIndexPath(indexPath) as! conversationCell
		
		if isEvent {
			if isAllUsers {
				if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
					cell.accessoryType = UITableViewCellAccessoryType.None
					self.removeFromList(cell.profileIdLabel.text!)
				} else {
					
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
					self.addToList(cell.profileIdLabel.text!)
				}
			}
			else {
				
				selectedPlayersUsername.removeAllObjects()
				
				selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
				selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
				println(selectedPlayersUsername)
				otherProfileName = cell.nameLabel.text!
				
				
				var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				
				let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
				
				//			controller.modalPresentationStyle = UIModalPresentationStyle.Popover
				
				
				println("STORYBOARD: \(controller.description)")
				
				self.presentViewController(controller, animated: true, completion: nil)

			}
		}
		
		if !isEvent {
			selectedPlayersUsername.removeAllObjects()
			
			selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
			selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
			println(selectedPlayersUsername)
			otherProfileName = cell.nameLabel.text!
			
			
			var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
			
			//			controller.modalPresentationStyle = UIModalPresentationStyle.Popover
			
			
			println("STORYBOARD: \(controller.description)")
			
			self.presentViewController(controller, animated: true, completion: nil)
		}

//		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		println("5")

		if !isEvent {
			return participantArray.count
		} else {
			if isAllUsers {
				return allTeamMemberArray.count
			} else {
				return eventParticipantArray.count
			}
		}

//		return roomPlayerNames[index].count + 1
	}

	func removeFromList(id:String) {
		for var i=0; i<eventParticipantIdArray.count; i++ {
			if id == eventParticipantIdArray[i] {
				eventParticipantIdArray.removeAtIndex(i)
				eventParticipantArray.removeAtIndex(i)
				break
			}
		}
	}
	
	func addToList(id:String) {
		eventParticipantIdArray.append(id)
		
		var query = PFUser.query()
		var object = query?.getObjectWithId(id)
		eventParticipantArray.append(object as? PFUser)
	}
	
	// MARK - ATLConversationListViewControllerDataSource Methods
	
	func conversationListViewController(conversationListViewController: ATLConversationListViewController, titleForConversation conversation: LYRConversation) -> String {
		if conversation.metadata["title"] != nil {
			println("asdf")
			return conversation.metadata["title"] as! String
		} else {
			let listOfParticipant = Array(conversation.participants)
			println("PARTICIPANTS:\(conversation.participants)")

			let unresolvedParticipants: NSArray = UserManager.sharedManager.unCachedUserIDsFromParticipants(listOfParticipant)
			println("UN-PARTICIPANTS:\(unresolvedParticipants)")
			let resolvedNames: NSArray = UserManager.sharedManager.resolvedNamesFromParticipants(listOfParticipant)
			println("Re-PARTICIPANTS:\(resolvedNames)")

			if (unresolvedParticipants.count > 0) {
				UserManager.sharedManager.queryAndCacheUsersWithIDs(unresolvedParticipants as! [String]) { (participants: NSArray?, error: NSError?) in
					if (error == nil) {
						if (participants?.count > 0) {
//							self.reloadCellForConversation(conversation)
						}
					} else {
						println("Error querying for Users: \(error)")
					}
				}
			}
			
			if (resolvedNames.count > 0 && unresolvedParticipants.count > 0) {
				let resolved = resolvedNames.componentsJoinedByString(", ")
				return "\(resolved) and \(unresolvedParticipants.count) others"
			} else if (resolvedNames.count > 0 && unresolvedParticipants.count == 0) {
				return resolvedNames.componentsJoinedByString(", ")
			} else {
				return "Conversation with \(conversation.participants.count) users..."
			}
		}
	}
	
	
	// MARK - ATLParticipantTableViewController Delegate Methods



	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
		println("participant: \(participant)")
		
		
//		selectedConversation.addParticipants(NSSet.setByAddingObject(participant as! AnyObject), error: nil)
		
		
//		self.addressBarController.selectParticipant(participant)
//		println("selectedParticipants: \(self.addressBarController.selectedParticipants)")
		//        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController!, didDeselectParticipant participant: ATLParticipant!) {
		
		//		self.addressBarController.
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

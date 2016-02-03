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
		
		if isEvent {
			
			self.title = "Event Participants"

			if isAllUsers {
				
				let title = NSLocalizedString("Select All",  comment: "")
				let saveItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleSelectTap"))
				saveItem.tintColor = UIColor.whiteColor()
				self.navigationItem.rightBarButtonItem = saveItem
			}
		} else {
			self.title = "Chat Room"
		}
		
		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)
    }
	
	override func viewDidAppear(animated: Bool) {
		
		self.fetchInfo()
	}
	
	func handleSelectTap() {
		
		let numRows = self.resultsTable.numberOfRowsInSection(0)
		
		for var i=0; i<numRows; i++ {
			let indexPath = NSIndexPath(forRow: i, inSection: 0)
			let cell = self.resultsTable.cellForRowAtIndexPath(indexPath) as! conversationCell
			
			if cell.accessoryType != UITableViewCellAccessoryType.Checkmark {
				cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				self.addToList(cell.profileIdLabel.text!)
			}

		}
	}
	
	func fetchInfo() {
		
		if isEvent {
			
			
			UserManager.sharedManager.queryForTeamUsersWithCompletion(selectedTeamId, includeCurrUser: true) { (users: NSArray?, error: NSError?) in
				if error == nil {
					let participants = NSSet(array: users as! [PFUser]) as! Set<PFUser>
					for participant in participants {
						allTeamMemberArray.append(participant)
					}
					self.resultsTable.reloadData()
					print(allTeamMemberArray)
				} else {
					print("Error querying for All Users: \(error)")
				}
			}
			
			if !isAllUsers {
				if let participants = selectedEvent[0].objectForKey("Participants") as? [String] {
					eventParticipantIdArray = participants
				} else {
					eventParticipantIdArray = []
				}
				
				let query = PFUser.query()
				query?.whereKey("objectId", containedIn: eventParticipantIdArray)
				query?.addAscendingOrder("firstName")
				query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
					
					if error == nil {
						for user: PFUser in (objects as! [PFUser]) {
							eventParticipantArray.append(user)
						}
						self.resultsTable.reloadData()
						print(eventParticipantArray)
					}
				})
			}
		}
	}
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! conversationCell
		
		if indexPath.section == 0 {
			
			self.populateTable(cell, indexPath: indexPath)

		}
		
		if indexPath.section == 1 {
			
			cell.profileImg.hidden = true
			cell.textLabel!.text = "Title"
			
			
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		let cell = tableView.cellForRowAtIndexPath(indexPath) as! conversationCell

		
		if indexPath.section == 0 {

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
					otherProfileName = cell.nameLabel.text!
					
					let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
					let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
					self.presentViewController(controller, animated: true, completion: nil)
					
				}
			}
			
			if !isEvent {
				selectedPlayersUsername.removeAllObjects()
				
				selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
				selectedPlayersUsername.addObject(cell.profileIdLabel.text!)
				print(selectedPlayersUsername)
				otherProfileName = cell.nameLabel.text!
				
				
				let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
                self.presentViewController(controller, animated: true, completion: nil)
			}
		}
		
		if indexPath.section == 1 {
		
			
		}
	}
	
	func populateTable(cell: conversationCell, indexPath: NSIndexPath){
		
		if cell.nameLabel.text == "" {
			
			if !isEvent {
								
				var currentUser = ""
				if participantArray[indexPath.row]!.objectId! == PFUser.currentUser()!.objectId {
					currentUser = "(me)"
				}
				
				let firstName = participantArray[indexPath.row]?.objectForKey("firstName") as! String
				let lastName = participantArray[indexPath.row]?.objectForKey("lastName") as! String
				
				cell.nameLabel.text = "\(firstName) \(lastName) \(currentUser)"
				cell.profileIdLabel.text = participantArray[indexPath.row]?.objectId
				
				if let file = participantArray[indexPath.row]?.objectForKey("photo") as? PFFile {
					let data = file.getData()
					let image = UIImage(data: data!)
					cell.profileImg.image = image
				}
				//		}
			}
			
			if isEvent {
				if isAllUsers {
					
					let firstName = allTeamMemberArray[indexPath.row]?.objectForKey("firstName") as! String
					let lastName = allTeamMemberArray[indexPath.row]?.objectForKey("lastName") as! String
					
					cell.nameLabel.text = "\(firstName) \(lastName)"
					cell.profileIdLabel.text = allTeamMemberArray[indexPath.row]?.objectId
					
					if let file = allTeamMemberArray[indexPath.row]?.objectForKey("photo") as? PFFile {
						let data = file.getData()
						let image = UIImage(data: data!)
						cell.profileImg.image = image
					}
					for var i=0; i<eventParticipantArray.count; i++ {
						
						if cell.profileIdLabel.text == eventParticipantArray[i]?.objectId {
							
							cell.accessoryType = UITableViewCellAccessoryType.Checkmark
						}
					}
					
				} else {
					
					let firstName = eventParticipantArray[indexPath.row]?.objectForKey("firstName") as! String
					let lastName = eventParticipantArray[indexPath.row]?.objectForKey("lastName") as! String
					
					cell.nameLabel.text = "\(firstName) \(lastName)"
					cell.profileIdLabel.text = eventParticipantArray[indexPath.row]?.objectId
					
					if let file = eventParticipantArray[indexPath.row]?.objectForKey("photo") as? PFFile {
						let data = file.getData()
						let image = UIImage(data: data!)
						cell.profileImg.image = image
					}
					
				}
			}
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if section == 0 {
			if !isEvent {
				return participantArray.count
			} else {
				if isAllUsers {
					return allTeamMemberArray.count
				} else {
					return eventParticipantArray.count
				}
			}
		}
		if section == 1 {
			return 1
		}
		else {
			return 0
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Participants"
		}
		if section == 1 {
			return "Conversation Title"
		}
		else {
			return ""
		}
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
		
		let query = PFUser.query()
		let object = query?.getObjectWithId(id)
		eventParticipantArray.append(object as? PFUser)
	}
	
	// MARK - ATLConversationListViewControllerDataSource Methods
	
	func conversationListViewController(conversationListViewController: ATLConversationListViewController, titleForConversation conversation: LYRConversation) -> String {
		if conversation.metadata["title"] != nil {
			return conversation.metadata["title"] as! String
		} else {
			let listOfParticipant = Array(conversation.participants)
			let unresolvedParticipants: NSArray = UserManager.sharedManager.unCachedUserIDsFromParticipants(listOfParticipant)
			let resolvedNames: NSArray = UserManager.sharedManager.resolvedNamesFromParticipants(listOfParticipant)

			if (unresolvedParticipants.count > 0) {
				UserManager.sharedManager.queryAndCacheUsersWithIDs(unresolvedParticipants as! [String]) { (participants: NSArray?, error: NSError?) in
					if (error == nil) {
						if (participants?.count > 0) {
//							self.reloadCellForConversation(conversation)
						}
					} else {
						print("Error querying for Users: \(error)")
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
	}
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController!, didDeselectParticipant participant: ATLParticipant!) {
	}
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSearchWithString searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
		UserManager.sharedManager.queryTeamForUserWithName(searchText, teamId:selectedTeamId) { (participants, error) in
			if (error == nil) {
				if let callback = completion {
					callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
				}
			} else {
				print("Error search for participants: \(error)")
			}
		}
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

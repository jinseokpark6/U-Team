//
//  TeamDashboardVC.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 8. 28..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

class TeamDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ATLParticipantTableViewControllerDelegate {

	@IBOutlet weak var teamPhoto: UIImageView!
	@IBOutlet weak var teamName: UILabel!
	@IBOutlet weak var resultsTable: UITableView!
	
	var announcements: [PFObject] = [PFObject]()
	
	
    override func viewDidLoad() {
		
		super.viewDidLoad()
		
        self.title = "Dashboard"
		
		teamPhoto.layer.cornerRadius = teamPhoto.bounds.height / 2
		teamPhoto.clipsToBounds = true
		
		if status == "Coach" {
			teamPhoto.userInteractionEnabled = true
		}
		
		teamName.text = selectedTeamName
		
		let tapViewGesture = UITapGestureRecognizer(target: self, action: "changePhoto")
		tapViewGesture.numberOfTapsRequired = 1
		self.teamPhoto.addGestureRecognizer(tapViewGesture)
		
		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)

        
        SVProgressHUD.show()
		fetchAnnouncementInfo()
        fetchTeamInfo()
        SVProgressHUD.dismiss()
		


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
		
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				cell.textLabel!.text = "Coach"
			}
			if indexPath.row == 1 {
				cell.textLabel!.text = "Player"
			}
			
			let detailButton = UITableViewCellAccessoryType.DisclosureIndicator
			cell.accessoryType = detailButton

		}
		if indexPath.section == 1 {
			
			if self.announcements.count != 0 {
				
				var notiString = ""
				
				for var i=0; i<announcements.count; i++ {
					let name = self.announcements[i].objectForKey("name") as! String
					let title = self.announcements[i].objectForKey("title") as! String
					
					if self.announcements[i].objectForKey("type") as! String == "Add Event" {
						notiString += "\(name) added '\(title)'" + "\n"
					}
					if self.announcements[i].objectForKey("type") as! String == "Update Event" {
						notiString += "\(name) updated '\(title)'" + "\n"
					}
					if self.announcements[i].objectForKey("type") as! String == "Add Note" {
						notiString += "\(name) added a note to '\(title)'" + "\n"
					}
				}
				notiString += "more..."

				cell.textLabel!.numberOfLines = 0
				cell.textLabel!.text = notiString
				let detailButton = UITableViewCellAccessoryType.DisclosureIndicator
				cell.accessoryType = detailButton

			}
			

		}
		
		if indexPath.section == 2 {
			cell.textLabel!.text = "View Team Details"
		}
		

		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				UserManager.sharedManager.queryForTeamCoachWithCompletion(selectedTeamId, includeCurrUser: true) { (users: NSArray?, error: NSError?) in
					if error == nil {
						let participants = NSSet(array: users as! [PFUser]) as Set<NSObject>
						let controller = ParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
						controller.delegate = self
						isModal = false
						self.navigationController!.pushViewController(controller, animated: true)
					} else {
						print("Error querying for All Users: \(error)")
					}
				}
			}
			if indexPath.row == 1 {
				UserManager.sharedManager.queryForTeamPlayersWithCompletion(selectedTeamId, includeCurrUser: true) { (users: NSArray?, error: NSError?) in
					if error == nil {
						let participants = NSSet(array: users as! [PFUser]) as Set<NSObject>
						let controller = ParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
						controller.delegate = self
						isModal = false
						self.navigationController!.pushViewController(controller, animated: true)
					} else {
						print("Error querying for All Users: \(error)")
					}
				}
			}
		}
		if indexPath.section == 1 {
			let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("TeamNotificationVC") as! TeamNotificationVC
			
			let nav = UINavigationController(rootViewController: controller)
			
			self.presentViewController(nav, animated: true, completion: nil)
			
//			self.navigationController!.pushViewController(controller, animated: true)
			
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			return 2
		}
		if section == 1 {
			return 1
		}
		else {
			return 0
		}
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 2
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Roster"
		}
		if section == 1 {
			return "Notification"
		}
		else {
			return ""
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 35
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.section == 0 {
			return 45
		}
		if indexPath.section == 1 {
			return 110
		}
		else {
			return 30
		}
	}
	
	
	// MARK - ATLParticipantTableViewController Delegate Methods
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
		print("participant: \(participant)")

		
		selectedPlayersUsername.removeAllObjects()
		
		selectedPlayersUsername.addObject(participant.participantIdentifier)
		selectedPlayersUsername.addObject(participant.participantIdentifier)
		print(selectedPlayersUsername)
		
		
		
		otherProfileName = participant.fullName


		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
		
		
		print("STORYBOARD: \(controller.description)")
		
		self.presentViewController(controller, animated: true, completion: nil)
		
		
		startAtUserVC = true
	
	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.None
	}

	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSearchWithString searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
		UserManager.sharedManager.queryForUserWithName(searchText) { (participants, error) in
			if (error == nil) {
				if let callback = completion {
					callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
				}
			} else {
				print("Error search for participants: \(error)")
			}
		}
	}

	
	func changePhoto() {
		
		let image = UIImagePickerController()
		image.delegate = self
		image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		image.allowsEditing = true
		self.presentViewController(image, animated: true, completion: nil)
	}
	
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		
		self.dismissViewControllerAnimated(true, completion: nil)
		
		let imageData = UIImagePNGRepresentation(image)
		let imageFile = PFFile(name: "teamPhoto.png", data: imageData!)
		
		let query = PFQuery(className:"Team")
		let pfObject = query.getObjectWithId(selectedTeamId)
		print(pfObject)
		
		pfObject?.setObject(imageFile, forKey: "photo")
		pfObject?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
			
			if error == nil {
				print("success")
				self.teamPhoto.image = image
			}
		})
	}
	
	
	func fetchAnnouncementInfo() {
		
		let query = PFQuery(className:"Team_Announcement")
		query.whereKey("teamId", equalTo:selectedTeamId)
		query.addDescendingOrder("createdAt")
		query.limit = 3
		query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
			
			if error == nil {
				for object in objects! {
					
					self.announcements.append(object as! PFObject)
				}
				
				self.resultsTable.reloadData()
			}
		}
	}
    
    func fetchTeamInfo() {
        let query = PFQuery(className:"Team")
        let pfObject = query.getObjectWithId(selectedTeamId)
        
        if let file = pfObject?.objectForKey("photo") as? PFFile {
            let imageData:NSData? = file.getData()
            teamPhoto.image = (UIImage(data: imageData!)!)
            
        }
    }

}

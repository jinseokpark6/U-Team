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
		
		
		var query = PFQuery(className:"Team")
		var pfObject = query.getObjectWithId(selectedTeamId)
		
		if let file = pfObject?.objectForKey("photo") as? PFFile {
			var imageData:NSData? = file.getData()
			teamPhoto.image = (UIImage(data: imageData!)!)
			
		}


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		
//		self.navigationController?.navigationBarHidden = false

	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
		
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				cell.textLabel!.text = "List of Players"
			}
		}
		if indexPath.section == 1 {
			cell.textLabel!.text = "View Recent Notifications"
		}
		
		if indexPath.section == 2 {
			cell.textLabel!.text = "View Team Details"
		}
		
		var detailButton = UITableViewCellAccessoryType.DisclosureIndicator
		cell.accessoryType = detailButton

		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				UserManager.sharedManager.queryForTeamUsersWithCompletion(selectedTeamId, includeCurrUser: true) { (users: NSArray?, error: NSError?) in
					if error == nil {
						let participants = NSSet(array: users as! [PFUser]) as Set<NSObject>
						let controller = ParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
						controller.delegate = self
						isModal = false
						self.navigationController!.pushViewController(controller, animated: true)
					} else {
						println("Error querying for All Users: \(error)")
					}
				}
			}
		}
		if indexPath.section == 1 {
			var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			var controller = storyboard.instantiateViewControllerWithIdentifier("TeamNotificationVC") as! TeamNotificationVC
			
			var nav = UINavigationController(rootViewController: controller)
			
			self.presentViewController(nav, animated: true, completion: nil)
			
//			self.navigationController!.pushViewController(controller, animated: true)
			
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 1
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 2
	}
	
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		return 50
	}
	
	
	// MARK - ATLParticipantTableViewController Delegate Methods
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
		println("participant: \(participant)")

		
		selectedPlayersUsername.removeAllObjects()
		
		selectedPlayersUsername.addObject(participant.participantIdentifier)
		selectedPlayersUsername.addObject(participant.participantIdentifier)
		println(selectedPlayersUsername)
		
		
		
		otherProfileName = participant.fullName


		var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("UserDetailVC") as! UserDetailVC
		
		
		println("STORYBOARD: \(controller.description)")
		
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
				println("Error search for participants: \(error)")
			}
		}
	}

	
	func changePhoto() {
		
		var image = UIImagePickerController()
		image.delegate = self
		image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		image.allowsEditing = true
		self.presentViewController(image, animated: true, completion: nil)
	}
	
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		
		self.dismissViewControllerAnimated(true, completion: nil)
		
		let imageData = UIImagePNGRepresentation(image)
		let imageFile = PFFile(name: "teamPhoto.png", data: imageData)
		
		var query = PFQuery(className:"Team")
		var pfObject = query.getObjectWithId(selectedTeamId)
		println(pfObject)
		
		pfObject?.setObject(imageFile, forKey: "photo")
		pfObject?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
			
			if error == nil {
				println("success")
				self.teamPhoto.image = image
			}
		})
	}

	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}

	override func shouldAutorotate() -> Bool {
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

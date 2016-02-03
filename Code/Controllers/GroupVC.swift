//
//  GroupVC.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 2015. 6. 7..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

var resultsTeamName:[String] = [String]()
var resultsTeamPhoto:[AnyObject] = [AnyObject]()
var resultsTeamId:[String] = [String]()
var resultsTeamObject = [PFObject]()


var status = ""

var selectedTeamId = ""
var selectedTeamName = ""
var selectedTeamObject = [PFObject]()

class GroupVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    @IBOutlet weak var teamView: UICollectionView!
	
	var teamNameArray = [String]()
	var teamIdArray = [String]()
    
	var layerClient: LYRClient!
	
	var passwordCheck = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Select Team"
		self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
		
		self.navigationItem.hidesBackButton = true
		
		
    }
	
	override func viewDidAppear(animated: Bool) {

        refresh()

		if isLogout {
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsTeamName.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell:groupCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! groupCell
		
        if resultsTeamName.count == indexPath.row  {
            cell.plusSign.hidden = false
            cell.textLabel.text = "Create Team"
            cell.imageView.hidden = true
			cell.teamLabel.hidden = true
        } else {
            cell.plusSign.hidden = true
			cell.textLabel.text = resultsTeamName[indexPath.row] as String

			if let photo = resultsTeamPhoto[indexPath.row] as? UIImage {
				cell.imageView.image = photo
				cell.teamLabel.hidden = true
				cell.imageView.hidden = false
				
			} else {
				cell.imageView.hidden = true
				cell.teamLabel.hidden = false
				let name = resultsTeamName[indexPath.row] as String
				let firstChar = Array(arrayLiteral: name)[0]
				cell.teamLabel.text = String(firstChar)
			}
        }
		
		cell.layer.cornerRadius = 10
		cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let theWidth = self.view.frame.width
		
		let width = (theWidth-75)/2
		let height = width+30
		
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsetsMake(25,25,25,25);

    }
    
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		
		selectedTeamId = resultsTeamId[indexPath.row]
		selectedTeamName = resultsTeamName[indexPath.row]
		selectedTeamObject.removeAll(keepCapacity: false)
		selectedTeamObject.append(resultsTeamObject[indexPath.row])

		teamJoin()
	}
	
	func alertPasswordMatchFail() {
		let infoAlert = UIAlertController(title: "Notification", message: "Password does not match", preferredStyle: UIAlertControllerStyle.Alert)
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
		}))
		self.presentViewController(infoAlert, animated: true, completion: nil)

	}
	
	func alertTeamPassword(newTeamArray: [String]) {
		let infoAlert = UIAlertController(title: "Notification", message: "Please Type Password", preferredStyle: UIAlertControllerStyle.Alert)
		infoAlert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            textField.placeholder = "Type here"
		}
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			let tf = (infoAlert.textFields?.first)! as UITextField
			let text = tf.text
			if selectedTeamObject[0].objectForKey("password") as? String == text {
				self.alertTeamJoin(newTeamArray)
			} else {
//				self.alertPasswordMatchFail()
			}
		}))
		infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
		}))
        
		self.presentViewController(infoAlert, animated: true, completion: nil)
	}
	
	func alertTeamJoin(newTeamArray: [String]){
		
		let infoAlert = UIAlertController(title: "Join Team", message: "Do you want to join \(selectedTeamName)?", preferredStyle: UIAlertControllerStyle.Alert)
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			let currentUser = PFUser.currentUser()
			currentUser?.setObject(newTeamArray, forKey: "team_id_array")
			currentUser?.save()
			
			self.createStatus()
			
		}))
		
		infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
		}))
		
		self.presentViewController(infoAlert, animated: true, completion: nil)
	}
	
	func teamJoin() {
		
		var newTeamArray: [String] = [String]()
		print(PFUser.currentUser())
		print(PFUser.currentUser()!.objectForKey("team_id_array"))
		
		let query = PFUser.query()
		let object = query?.getObjectWithId((PFUser.currentUser()?.objectId!)!)
		
		
		if let teamArray = object?.objectForKey("team_id_array") as? [String] {
			
			newTeamArray = teamArray
            
			// check if the user is already part of the team
			var isFound = false
			for var i=0; i<teamArray.count; i++ {
				if teamArray[i] == selectedTeamId {
					isFound = true
					self.checkStatus()
					break
				}
			}
			if !isFound {
				
				newTeamArray.append(selectedTeamId)

				// check for password
				if let _ = selectedTeamObject[0].objectForKey("password") as? String {
					alertTeamPassword(newTeamArray)
				} else {
					alertTeamJoin(newTeamArray)
				}
			}
		} else {
			
			newTeamArray.append(selectedTeamId)

			// check for password
			if let _ = selectedTeamObject[0].objectForKey("password") as? String {
				alertTeamPassword(newTeamArray)
			} else {
				alertTeamJoin(newTeamArray)
			}
		}
	}
	
	func checkStatus() {
		
		let query = PFQuery(className:"Team")
		let pfObject = query.getObjectWithId(selectedTeamId)
		if let array = pfObject?.objectForKey("coach") as? [String] {
			
			var isFound = false
			for var i=0; i<array.count; i++ {
				if array[i] == PFUser.currentUser()?.objectId {
					isFound = true
					break
				}
			}
			if isFound {
				status = "Coach"
			} else {
				status = "Player"
			}
		}
		self.enterTeam()

	}
	
	func createStatus() {
		
		let infoAlert = UIAlertController(title: "Check Status", message: "Are you a coach or a player?", preferredStyle: UIAlertControllerStyle.Alert)
		
		infoAlert.addAction(UIAlertAction(title: "Coach", style: .Default, handler: { (action:UIAlertAction!) -> Void in

			let query = PFQuery(className:"Team")
			let pfObject = query.getObjectWithId(selectedTeamId)
			
			var newArray:[String] = [String]()
			if let array = pfObject?.objectForKey("coach") as? [String] {
				newArray = array
				newArray.append((PFUser.currentUser()?.objectId!)!)
			} else {
				newArray.append((PFUser.currentUser()?.objectId!)!)
			}
			pfObject?.setObject(newArray, forKey: "coach")
			pfObject?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
				
				if error == nil {
					status = "Coach"
					self.enterTeam()
				}
			})
		}))
		
		infoAlert.addAction(UIAlertAction(title: "Player", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			let query = PFQuery(className:"Team")
			let pfObject = query.getObjectWithId(selectedTeamId)
			
			var newArray:[String] = [String]()
			if let array = pfObject?.objectForKey("players") as? [String] {
				newArray = array
				newArray.append((PFUser.currentUser()?.objectId!)!)
			} else {
				newArray.append((PFUser.currentUser()?.objectId!)!)
			}
			pfObject?.setObject(newArray, forKey: "players")
			pfObject?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
				
				if error == nil {
					status = "Player"
					self.enterTeam()
				}
			})
		}))
		self.presentViewController(infoAlert, animated: true, completion: nil)
	}
	
	
	func enterTeam() {
		
		let tabBarController: UITabBarController = UITabBarController()
        let navigationController1: UINavigationController = UINavigationController()
        let controller1 = self.storyboard!.instantiateViewControllerWithIdentifier("TeamDashboardVC") as! TeamDashboardVC
		let navigationController2: UINavigationController = UINavigationController()
		let controller2: ConversationListViewController = ConversationListViewController(layerClient: self.layerClient)
		let navigationController3: UINavigationController = UINavigationController()
		let controller3 = self.storyboard!.instantiateViewControllerWithIdentifier("CalendarPortraitViewController") as! CalendarPortraitViewController
		let navigationController4: UINavigationController = UINavigationController()
		let controller4 = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsVC
		controller4.layerClient = self.layerClient

		
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 22) as! AnyObject]
		
		navigationController1.tabBarItem.title = "Dashboard"
		navigationController1.tabBarItem.image = UIImage(named:"activity_feed_2.png")
		navigationController1.addChildViewController(controller1)
		tabBarController.addChildViewController(navigationController1)

		navigationController2.tabBarItem.title = "Chat"
		navigationController2.tabBarItem.image = UIImage(named:"chat.png")
		navigationController2.addChildViewController(controller2)
		tabBarController.addChildViewController(navigationController2)

		navigationController3.tabBarItem.title = "Calendar"
		navigationController3.tabBarItem.image = UIImage(named:"planner.png")
		navigationController3.addChildViewController(controller3)
		tabBarController.addChildViewController(navigationController3)
		
		navigationController4.tabBarItem.title = "Profile"
		navigationController4.tabBarItem.image = UIImage(named:"guest.png")
		navigationController4.addChildViewController(controller4)
		tabBarController.addChildViewController(navigationController4)

		self.navigationController?.presentViewController(tabBarController, animated: true, completion: nil)

	}
	
	
	func refresh() {
		
		resultsTeamObject.removeAll(keepCapacity: false)
		resultsTeamName.removeAll(keepCapacity: false)
		resultsTeamId.removeAll(keepCapacity: false)
		resultsTeamPhoto.removeAll(keepCapacity: false)
		
		let teamQuery = PFQuery(className: "Team")
		teamQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
			
			for object in objects! {
				resultsTeamObject.append(object as! PFObject)
				
				let teamName = object.objectForKey("name") as! String
				resultsTeamName.append(teamName)
				resultsTeamId.append((object.objectId!)!)
				
				if let photo = object.objectForKey("photo") as? PFFile {
					let imageData = photo.getData()
					let image = UIImage(data: imageData!)
					resultsTeamPhoto.append(image!)
				} else {
					resultsTeamPhoto.append("")
				}
			}
			self.teamView.reloadData()
		}
	}
}


extension ATLAddressBarViewController {
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}


extension ATLTypingIndicatorViewController {
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UITabBarController {
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UIAlertController {
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UINavigationController {
	public override func shouldAutorotate() -> Bool {
		return false
	}
}





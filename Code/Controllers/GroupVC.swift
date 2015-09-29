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

		
		if isLogout == true {

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

        var cell:groupCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! groupCell
		
		
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
				var name = resultsTeamName[indexPath.row] as String
				var firstChar = Array(name)[0]
				cell.teamLabel.text = String(firstChar)
			}
			
        }
		
		
		cell.layer.cornerRadius = 10
		cell.clipsToBounds = true
		


		
//        cell.layer.cornerRadius = cell.frame.size.height/2
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var theWidth = self.view.frame.width
		
		var width = (theWidth-75)/2
		var height = width+30
		
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
		
		var infoAlert = UIAlertController(title: "Notification", message: "Password does not match", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
		}))
		
		self.presentViewController(infoAlert, animated: true, completion: nil)

	}
	
	func alertTeamPassword(newTeamArray: [String]) {
		
		
		var infoAlert = UIAlertController(title: "Notification", message: "Please Type Password", preferredStyle: UIAlertControllerStyle.Alert)
		
		infoAlert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
			
			textField.placeholder = "Type here"
		}
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			var tf = infoAlert.textFields?.first as? UITextField
			var text = tf!.text
			
			if selectedTeamObject[0].objectForKey("password") as! String == text {
				
				println("checked")
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
		
		var infoAlert = UIAlertController(title: "Join Team", message: "Do you want to join \(selectedTeamName)?", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			var currentUser = PFUser.currentUser()
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
		println(PFUser.currentUser())
		println(PFUser.currentUser()!.objectForKey("team_id_array"))
		
		var query = PFUser.query()
		var object = query?.getObjectWithId((PFUser.currentUser()?.objectId!)!)
		
		
		if let teamArray = object?.objectForKey("team_id_array") as? [String] {
			
			newTeamArray = teamArray
			
			println("teamarray \(newTeamArray)")

			
			// check if the user is already part of the team
			var isFound = false
			for var i=0; i<teamArray.count; i++ {
				if teamArray[i] == selectedTeamId {
					isFound = true
					println("asdf \(teamArray[i])")
					self.checkStatus()
					break
				}
			}
			
			if !isFound {
				
				newTeamArray.append(selectedTeamId)

				// check for password
				if let password = selectedTeamObject[0].objectForKey("password") as? String {
					
					alertTeamPassword(newTeamArray)
					
				} else {
					
					alertTeamJoin(newTeamArray)
				}
			}
			
		} else {
			
			newTeamArray.append(selectedTeamId)

			// check for password
			if let password = selectedTeamObject[0].objectForKey("password") as? String {
				
				alertTeamPassword(newTeamArray)
				
			} else {
				
				alertTeamJoin(newTeamArray)
			}
		}
	}
	
	func checkStatus() {
		
		var query = PFQuery(className:"Team")
		var pfObject = query.getObjectWithId(selectedTeamId)
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
		
		
		
		var infoAlert = UIAlertController(title: "Check Status", message: "Are you a coach or a player?", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "Coach", style: .Default, handler: { (action:UIAlertAction!) -> Void in


			var query = PFQuery(className:"Team")
			var pfObject = query.getObjectWithId(selectedTeamId)
			
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
			
			var query = PFQuery(className:"Team")
			var pfObject = query.getObjectWithId(selectedTeamId)
			
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
		let controller1: ConversationListViewController = ConversationListViewController(layerClient: self.layerClient)
		
		
		
		let navigationController2: UINavigationController = UINavigationController()
		var controller2 = self.storyboard!.instantiateViewControllerWithIdentifier("TeamDashboardVC") as! TeamDashboardVC
		
		
		let navigationController3: UINavigationController = UINavigationController()
		var controller3 = self.storyboard!.instantiateViewControllerWithIdentifier("CalendarPortraitViewController") as! CalendarPortraitViewController
		
		let navigationController4: UINavigationController = UINavigationController()
		var controller4 = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsVC
		controller4.layerClient = self.layerClient

		

		navigationController2.tabBarItem.title = "Dashboard"
		navigationController2.tabBarItem.image = UIImage(named:"activity_feed_2.png")
		navigationController2.addChildViewController(controller2)
		tabBarController.addChildViewController(navigationController2)

		navigationController1.tabBarItem.title = "Messages"
		navigationController1.tabBarItem.image = UIImage(named:"chat.png")
		navigationController1.addChildViewController(controller1)
		tabBarController.addChildViewController(navigationController1)

		navigationController3.tabBarItem.title = "Calendar"
		navigationController3.tabBarItem.image = UIImage(named:"planner.png")
		navigationController3.addChildViewController(controller3)
		tabBarController.addChildViewController(navigationController3)
		
		navigationController4.tabBarItem.title = "Profile"
		navigationController4.tabBarItem.image = UIImage(named:"guest.png")
		navigationController4.addChildViewController(controller4)
		tabBarController.addChildViewController(navigationController4)

		println("interfaces: \(navigationController2.supportedInterfaceOrientations())")
		println("interfacessssss: \(tabBarController.supportedInterfaceOrientations())")

//		tabBarController.supportedInterfaceOrientations()

		self.navigationController?.presentViewController(tabBarController, animated: true, completion: nil)

	}
	
	
	func refresh() {
		

		resultsTeamObject.removeAll(keepCapacity: false)
		resultsTeamName.removeAll(keepCapacity: false)
		resultsTeamId.removeAll(keepCapacity: false)
		resultsTeamPhoto.removeAll(keepCapacity: false)
		
		var teamQuery = PFQuery(className: "Team")
		teamQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
			
			for object in objects! {
				resultsTeamObject.append(object as! PFObject)
				
				var teamName = object.objectForKey("name") as! String
				resultsTeamName.append(teamName)
				resultsTeamId.append((object.objectId!)!)
				
				if let photo = object.objectForKey("photo") as? PFFile {
					var imageData = photo.getData()
					var image = UIImage(data: imageData!)
					resultsTeamPhoto.append(image!)
				} else {
					resultsTeamPhoto.append("")
				}
			}
			
			self.teamView.reloadData()
		}
		

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


extension ATLAddressBarViewController {
	public override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}


extension ATLTypingIndicatorViewController {
	public override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UITabBarController {
	public override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UIAlertController {
	public override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}
	public override func shouldAutorotate() -> Bool {
		return false
	}
}

extension UINavigationController {
	public override func supportedInterfaceOrientations() -> Int {
		return UIInterfaceOrientation.Portrait.rawValue
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}
}



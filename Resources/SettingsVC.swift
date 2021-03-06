//
//  SettingsVC.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 2015. 6. 17..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit



class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate
, UIImagePickerControllerDelegate {


    @IBOutlet weak var resultsTable: UITableView!
//    @IBOutlet weak var collectionView: UICollectionView!
	
    var resultsImageFile:PFFile? = PFFile()
	var resultsImages:[UIImage] = [UIImage]()

//    @IBOutlet weak var editBtn: UIButton!
//    @IBOutlet weak var editView: UIView!
	
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var profileNameLabel: UILabel!
	
	var layerClient: LYRClient!
	

	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
		self.profileImageView.clipsToBounds = true
		self.profileImageView.userInteractionEnabled = true
		self.profileImageView.layer.borderWidth = 0.3
		
		let tapViewGesture = UITapGestureRecognizer(target: self, action: "changePhoto")
		tapViewGesture.numberOfTapsRequired = 1
		self.profileImageView.addGestureRecognizer(tapViewGesture)

		

		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)
		

		let currentUser = PFUser.currentUser()

		if let file = currentUser?.objectForKey("photo") as? PFFile {
			self.resultsImageFile = file
			let imageData:NSData? = self.resultsImageFile!.getData()
			
			profileImageView.image = (UIImage(data: imageData!)!)
			
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		
		self.updateName()

	}
	
	func updateName() {
		
		let currentUser = PFUser.currentUser()

		if let currentUser = currentUser {
			
			var firstName = ""
			var lastName = ""
			if let first = currentUser.objectForKey("firstName") as? String {
				firstName = first
			}
			if let last = currentUser.objectForKey("lastName") as? String {
				lastName = last
			}
			let fullName = "\(firstName) \(lastName)"
			
			self.profileNameLabel.text = fullName
			
			
		}
	}
    
    

    
    
    @IBAction func logOutBtn_click(sender: AnyObject) {
        
		self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError?) in
			if error == nil {
				PFUser.logOut()
				
				isLogout = true
				
				self.dismissViewControllerAnimated(true, completion: { () -> Void in
					
					self.navigationController?.popToRootViewControllerAnimated(true)
				})
				
			} else {
				print("Failed to deauthenticate: \(error)")
			}
		}

	}
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
				let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				
				let controller = storyboard.instantiateViewControllerWithIdentifier("ProfileDetailVC") as! ProfileDetailVC
			
				let nav = UINavigationController(rootViewController: controller)
				self.presentViewController(nav, animated: true, completion: nil)

			}
            if (indexPath.row == 1) {
				
            }
            if (indexPath.row == 2) {
				
				self.dismissViewControllerAnimated(true, completion: nil)
			}
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
				
				self.dismissViewControllerAnimated(true, completion: nil)

				
			}
		}
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: settingsCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! settingsCell
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel!.text = "Update Profile"
				cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            if (indexPath.row == 1) {
                cell.textLabel!.text = "Update PhotoLine (coming soon)"
				cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            if (indexPath.row == 2) {
            }
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
				
				cell.textLabel!.text = "Change Team"
				cell.textLabel?.textColor = UIColor.blueColor()
				cell.textLabel?.textAlignment = NSTextAlignment.Center

//				cell.textLabel!.text = "Leave Team"
//				cell.textLabel!.textAlignment = NSTextAlignment.Center
//				cell.textLabel!.textColor = UIColor.redColor()
//                cell.selectionStyle = UITableViewCellSelectionStyle.None;
//                
//                cell.textLabel!.text = "Notifications"
//            
//                var switchView = UISwitch(frame: CGRectZero)
//                switchView.tag = 111
//                cell.accessoryView = switchView
//            
//                switchView.addTarget(self, action: "updateSwitch:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
		

        
        return cell
        
    }
    
    func updateSwitch(mySwitch: UISwitch) {
		
		let currentUser = PFUser.currentUser()
		
		if let currentUser = currentUser {
			
			print(currentUser)
			if let notification = currentUser.objectForKey("notification") as? String {
				print(notification)
				if notification == "0" {
					mySwitch.on = true
				} else {
					mySwitch.on = false
				}
				print("2")
			}
		}
		
        if mySwitch.on {
            mySwitch.setOn(true, animated:true)
			if let currentUser = currentUser {
				currentUser["notification"] = "0"
				currentUser.save()
			}
        } else {
            mySwitch.setOn(false, animated:true)
			if let currentUser = currentUser {
				currentUser["notification"] = "1"
				currentUser.save()
			}
        }
		
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 1 && indexPath.row == 0 {
			return 50
		} else {
			return 45
		}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return 2
        } else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Info"
        } else {
            return ""
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
        if let imageData = imageData {
            let imageFile = PFFile(name: "profile1.png", data: imageData)
            
            let currentUser = PFUser.currentUser()
            
            if let currentUser = currentUser {
                currentUser["photo"] = imageFile as PFFile
                currentUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if error == nil {
                        print("success")
                        self.profileImageView.image = image
                    }
                })
            }
        }
	}
	
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

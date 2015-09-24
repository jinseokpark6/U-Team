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
		
		self.title = "Profile"
		
		
		self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
		self.profileImageView.clipsToBounds = true
		self.profileImageView.userInteractionEnabled = true
		self.profileImageView.layer.borderWidth = 0.3
		
		let tapViewGesture = UITapGestureRecognizer(target: self, action: "changePhoto")
		tapViewGesture.numberOfTapsRequired = 1
		self.profileImageView.addGestureRecognizer(tapViewGesture)

		

		self.resultsTable.tableFooterView = UIView(frame: CGRectZero)
		

		var currentUser = PFUser.currentUser()

		if let file = currentUser?.objectForKey("photo") as? PFFile {
			self.resultsImageFile = file
			var imageData:NSData? = self.resultsImageFile!.getData()
			
			profileImageView.image = (UIImage(data: imageData!)!)
			
		}
		println("2")


    }
	
	override func viewDidAppear(animated: Bool) {
		
		self.updateName()

	}
	
	func updateName() {
		
		var currentUser = PFUser.currentUser()

		if let currentUser = currentUser {
			
			var firstName = ""
			var lastName = ""
			if let first = currentUser.objectForKey("firstName") as? String {
				firstName = first
			}
			if let last = currentUser.objectForKey("lastName") as? String {
				lastName = last
			}
			var fullName = "\(firstName) \(lastName)"
			
			self.profileNameLabel.text = fullName
			
			println("3")
			
		}
	}
    
    
    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return resultsImages.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        
//        var cell:settingsCell2 = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! settingsCell2
//        
//		
//        if resultsImages.count != indexPath.row {
//            
//            cell.imageView.image = resultsImages[indexPath.row]
//        }
//        
//        //        cell.backgroundColor = UIColor.blueColor()
//        return cell
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        return CGSize(width: self.collectionView.frame.size.height, height: self.collectionView.frame.size.height)
//    }
//    
//    
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        
//        
//        return UIEdgeInsetsMake(0,0,0,0)
//        
//    }
//    
//
//    
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return 0
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return 0
//	}
	
    
    
    
    

//    @IBAction func changePhoto(sender: AnyObject) {
//        
//        var image = UIImagePickerController()
//        image.delegate = self
//        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        image.allowsEditing = true
//        self.presentViewController(image, animated: true, completion: nil)
//
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        
//        profileImageView.image = image
//        self.dismissViewControllerAnimated(true, completion: nil)
//        
//        
//        
//        let imageData = UIImagePNGRepresentation(self.profileImageView.image)
//        let imageFile = PFFile(name: "profile.png", data: imageData)
//        
//        var currentUser = PFUser.currentUser()
//
//        if let user = currentUser {
//
//            user["photo"] = imageFile as PFFile
//        
//            user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
//            
//                if error == nil {
//                
//                } else {
//                    println(error!.description)
//                }
//        })
//        }
//    }

    
    
    @IBAction func logOutBtn_click(sender: AnyObject) {
        
		self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError?) in
			if error == nil {
				PFUser.logOut()
				
				isLogout = true
				
				self.dismissViewControllerAnimated(true, completion: { () -> Void in
					
					println("HI")
					self.navigationController?.popToRootViewControllerAnimated(true)
				})
				
			} else {
				println("Failed to deauthenticate: \(error)")
			}
		}

	}
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
				var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				
				var controller = storyboard.instantiateViewControllerWithIdentifier("ProfileDetailVC") as! ProfileDetailVC
			
				var nav = UINavigationController(rootViewController: controller)
				self.presentViewController(nav, animated: true, completion: nil)
//				self.navigationController?.pushViewController(controller, animated: true)

			}
            if (indexPath.row == 1) {
				
            }
            if (indexPath.row == 2) {
				
				self.dismissViewControllerAnimated(true, completion: nil)
			}
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
				
				var query = PFQuery(className:"Team")
				query.whereKey("objectId", equalTo:selectedTeamId)
				query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
					
					if error == nil {
						
						if let object = object {
							if status == "Coach" {
								
								var coachArray = object.objectForKey("coach") as! [String]
								
								for var i=0; i<coachArray.count; i++ {
									if coachArray[i] == PFUser.currentUser()!.objectId! {
										
										coachArray.removeAtIndex(i)
										break
									}
								}
								
								object["coach"] = coachArray
								object.saveInBackgroundWithBlock { (success, error) -> Void in

									if error == nil {
										
										self.dismissViewControllerAnimated(true, completion: { () -> Void in
											
											println("HI")
											self.navigationController?.popToRootViewControllerAnimated(true)
										})
									}
								}
							}
							
							if status == "Player" {
								
								var playerArray = object.objectForKey("players") as! [String]
								
								for var i=0; i<playerArray.count; i++ {
									if playerArray[i] == PFUser.currentUser()!.objectId! {
										
										playerArray.removeAtIndex(i)
										break
									}
								}
								
								object["players"] = playerArray
								object.saveInBackgroundWithBlock { (success, error) -> Void in
									
									if error == nil {
										
										self.dismissViewControllerAnimated(true, completion: { () -> Void in
											
											println("HI")
											self.navigationController?.popToRootViewControllerAnimated(true)
										})
									}
								}
							}
						}
					}
				})
			}
		}
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: settingsCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! settingsCell
        
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
                cell.textLabel!.text = "Change Team"
				cell.textLabel?.textColor = UIColor.blueColor()
				cell.textLabel?.textAlignment = NSTextAlignment.Center
            }
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
				
				cell.textLabel!.text = "Leave Team"
				cell.textLabel!.textAlignment = NSTextAlignment.Center
				cell.textLabel!.textColor = UIColor.redColor()
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
		
		var currentUser = PFUser.currentUser()
		
		if let currentUser = currentUser {
			
			println(currentUser)
			if let notification = currentUser.objectForKey("notification") as? String {
				println(notification)
				if notification == "0" {
					mySwitch.on = true
				} else {
					mySwitch.on = false
				}
				println("2")
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
		if indexPath.section == 0 && indexPath.row == 2 {
			return 55
		} else {
			return 45
		}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return 3
        } else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
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
		
		var image = UIImagePickerController()
		image.delegate = self
		image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		image.allowsEditing = true
		self.presentViewController(image, animated: true, completion: nil)
	}

	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		
		self.dismissViewControllerAnimated(true, completion: nil)
		
		let imageData = UIImagePNGRepresentation(image)
		let imageFile = PFFile(name: "profile1.png", data: imageData)
		
		var currentUser = PFUser.currentUser()
		
		if let user = currentUser {
			user["photo"] = imageFile as PFFile
			user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
				if error == nil {
					println("success")
					self.profileImageView.image = image
				}
			})
		}
	}
	
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

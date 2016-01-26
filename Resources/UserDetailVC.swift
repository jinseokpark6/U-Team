//
//  UserDetailVC.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 2015. 7. 22..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit

var startAtUserVC = false

var selectedPlayersProfileName = NSMutableArray()
var selectedPlayersUsername = NSMutableArray()
var selectedPlayersProfileImg = NSMutableArray()
var selectedPlayersObject = [PFObject]()
var otherProfileName = ""


class UserDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var dragView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var cancelView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
    
    let panRec = UIPanGestureRecognizer()
	
	
	var gravity: UIGravityBehavior!
	var animator: UIDynamicAnimator!
	var collision: UICollisionBehavior!
	
    var resultsImageFile:PFFile? = PFFile()
    var selectedPlayersImages:[UIImage?] = [UIImage]()
	
    var sportsLabel:String?
	var positionLabel:String?
    var schoolLabel:String?
    var regionLabel:String?
	
	var phoneLabel:String?
    
	@IBOutlet weak var swipeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = otherProfileName
		
		self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
		self.profileImageView.clipsToBounds = true

		self.profileImageView.layer.borderWidth = 0.3
		
        self.cancelView.layer.cornerRadius = self.cancelView.frame.height/2
        self.cancelView.clipsToBounds = true
        
        self.buttonView.layer.zPosition = 20
        self.collectionView.layer.zPosition = 10
        
        panRec.addTarget(self, action:"draggedView:")
        self.dragView.addGestureRecognizer(panRec)
        self.dragView.userInteractionEnabled = true
		
        
        
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: selectedPlayersUsername[1])
        
        let objects = query.findObjects()
        
        
        for object in objects! {
            
//            var i = 1
			
            if let photo = object["photoLine1"] as? PFFile {

                self.resultsImageFile = photo
                let imageData:NSData? = self.resultsImageFile!.getData()

                selectedPlayersImages.append(UIImage(data: imageData!))
				
				self.collectionView.reloadData()
				
//                i += 1
            }
			
			if let file = object["photo"] as? PFFile {
				
				let data = file.getData()
				let photo = UIImage(data: data!)
				self.profileImageView.image = photo
			}
            
            if let sports = object["Sports"] as? String {
                sportsLabel = sports
			} else {
				sportsLabel = ""
			}
			if let position = object["Position"] as? String {
				positionLabel = position
			} else {
				positionLabel = ""
			}
            if let school = object["School"] as? String {
                schoolLabel = school
			} else {
				schoolLabel = ""
			}
            if let region = object["Region"] as? String {
                regionLabel = region
			} else {
				regionLabel = ""
			}
			
			if let phone = object["phone"] as? String {
				phoneLabel = phone
			} else {
				phoneLabel = ""
			}
        }        // Do any additional setup after loading the view.
    }
    
        //        self.resultsTable.bounds.width = self.view.bounds.width
        //        self.resultsTable.bounds.height = self.view.bounds.height
        
        // Do any additional setup after loading the view.
    
	
	//swiping function
    func draggedView(sender:UIPanGestureRecognizer){
		
        self.view.bringSubviewToFront(sender.view!)
        let translation = sender.translationInView(self.view)
        
        let newCenter = CGPointMake(0, sender.view!.center.y + translation.y)
        
        let totalHeight = self.view.frame.height
		
		//if center of the bar is between the two end points
        if newCenter.y >= totalHeight - 180 - 135 && newCenter.y <= totalHeight - 135 {
			
            sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y + translation.y)
            print("TRANSLATION: \(translation.y)")
            self.collectionView2.center = CGPointMake(self.collectionView2.center.x, self.collectionView2.center.y + translation.y)

//            self.resultsTable.alpha = (540 - newCenter.y) / 180
            sender.setTranslation(CGPointZero, inView: self.view)
			
			
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            let velocity = sender.velocityInView(self.view)
			print("newCenter0:\(velocity.y):\(newCenter.y):\(totalHeight)")

            if velocity.y > 0 || (velocity.y == 0 && newCenter.y > totalHeight-120-40-90) {

				print("newCenter:\(velocity.y):\(sender.view!.frame.origin.y)")

//                self.collectionView.frame.origin = CGPointMake(0,0)
                self.collectionView2.frame.origin = CGPointMake(0,totalHeight-120)
//                self.resultsTable.alpha = 0
                sender.view!.frame.origin = CGPointMake(0,totalHeight-120-40)
				
				self.swipeLabel.text = "swipe up for more info"

				self.bottomConstraint.constant = 0

				
            } else {
				
				print("newCenter2:\(sender.view!.frame.origin.y)")

//                self.collectionView.frame.origin = CGPointMake(0,-90)
                self.collectionView2.frame.origin = CGPointMake(0,totalHeight-120-180)
//                self.resultsTable.alpha = 1
                sender.view!.frame.origin = CGPointMake(0,totalHeight-120-180-40)

				self.swipeLabel.text = "swipe down for less info"
				
				self.bottomConstraint.constant = 180

				
            }
        }
        


    }
    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
////        if snap != nil {
////            
////        }
//
//        let touch = touches.anyObject() as UITouch
//        snap = UISnapBehavior(item: , snapToPoint: touch.)
//        
//    }
	

    @IBAction func cancelBtn_click(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func messageBtn_click(sender: AnyObject) {
        
        //self.storyboard!.instantiateViewControllerWithIdentifier("ConversationVC") as! UIViewController
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("ConversationVC")
            
            self.showViewController(vc as! UIViewController, sender: vc)

            
        })
        
//        self.performSegueWithIdentifier("goToConversationVC", sender: self)
        
        //self.presentViewController(viewControllerToPresent: UIViewController, animated: true, completion: nil)
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView {
            return 1
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		
        if collectionView == self.collectionView {
			if selectedPlayersImages.count != 0 {
				return selectedPlayersImages.count
			} else {
				return 1
			}
        } else {
            return 3
        }
    }
	
	
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		
		if indexPath.item == 0 {
			print("HI \(self.phoneLabel)")
			
			self.makeCall()
			
		}
		if indexPath.item == 1 {
			self.comingSoon()
		}
		if indexPath.item == 2 {
			self.comingSoon()
		}
		
//		var cell = collectionView.cellForItemAtIndexPath(indexPath)
//		
//		cell?.backgroundColor = UIColor.grayColor()

	}
	
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            let cell:detailCell2 = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! detailCell2
            
            
            
            if selectedPlayersImages.count != indexPath.row {
                
                cell.imageView.image = selectedPlayersImages[indexPath.row]
            }
            
            //        cell.backgroundColor = UIColor.blueColor()
            return cell
        } else {
            let cell:detailCell3 = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! detailCell3
            
            if indexPath.row == 0 {
				cell.imageView.image = UIImage(named:"phone.png")
            }
            if indexPath.row == 1 {
				cell.imageView.image = UIImage(named:"speech_bubble.png")
            }
            if indexPath.row == 2 {
				cell.imageView.image = UIImage(named:"good_decision.png")
            }
            
            cell.layer.cornerRadius = cell.frame.size.width/2
            cell.clipsToBounds = true
            
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: self.collectionView.frame.size.height, height: self.collectionView.frame.size.height)
        } else {
            return CGSize(width: 72, height: 72)
        }
    }


    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if collectionView == self.collectionView {
            return UIEdgeInsetsMake(0,0,0,0)

        } else {
            let left = (self.collectionView2.frame.size.width - 144)/4
                return UIEdgeInsetsMake(24,left,24,left)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
	

	
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
            }
            if (indexPath.row == 1) {
            }
            if (indexPath.row == 2) {
            }
            
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: detailCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! detailCell
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.label1.text = "Sports"
                cell.label2.text = sportsLabel
            }
			if (indexPath.row == 1) {
				cell.label1.text = "Position"
				cell.label2.text = positionLabel
			}
            if (indexPath.row == 2) {
                cell.label1.text = "School"
                cell.label2.text = schoolLabel
            }
            if (indexPath.row == 3) {
                cell.label1.text = "Region"
                cell.label2.text = regionLabel
            }
        }
        
//        if (indexPath.section == 1) {
//            if (indexPath.row == 0) {
//                
//                cell.selectionStyle = UITableViewCellSelectionStyle.None;
//                
//                cell.textLabel!.text = "Stay Connected"
//                
//                var switchView = UISwitch(frame: CGRectZero)
//                switchView.tag = 111
//                cell.accessoryView = switchView
//                
//                switchView.addTarget(self, action: "updateSwitch:", forControlEvents: UIControlEvents.TouchUpInside)
//            }
//        }
		
        return cell
        
    }
    
    func updateSwitch(mySwitch: UISwitch) {
        
        if mySwitch.on {
            mySwitch.setOn(true, animated:true)
        } else {
            mySwitch.setOn(false, animated:true)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return 4
        } else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return ""
        } else {
            return ""
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func makeCall() {
		
		if self.phoneLabel == "" {
			
		}
		let infoAlert = UIAlertController(title: "Contact", message: "\(self.phoneLabel!)", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "Call", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			let url = NSURL(string: "tel://\(self.phoneLabel!)")
			UIApplication.sharedApplication().openURL(url!)

			
		}))
		
		infoAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
		}))
		
		self.presentViewController(infoAlert, animated: true, completion: nil)

	}
	
	func comingSoon() {
		
		let infoAlert = UIAlertController(title: "Notification", message: "Coming Soon", preferredStyle: UIAlertControllerStyle.Alert)
		
		
		infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
			
			
		}))
		
		
		self.presentViewController(infoAlert, animated: true, completion: nil)

	}
	
	
//	public override func supportedInterfaceOrientations() -> Int {
//		return UIInterfaceOrientation.Portrait.rawValue
//	}
//	
//	public override func shouldAutorotate() -> Bool {
//		return false
//	}

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

//
//  TeamNotificationVC.swift
//  
//
//  Created by Jin Seok Park on 2015. 9. 3..
//
//

import UIKit

class TeamNotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var announcements = [PFObject]()
	
	
	@IBOutlet weak var resultsTable: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool) {
		
		announcements.removeAll(keepCapacity: false)
		self.fetchInfo()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! teamNotificationCell
		
		let name = self.announcements[indexPath.row].objectForKey("name") as! String
		let title = self.announcements[indexPath.row].objectForKey("title") as! String
		let date = self.announcements[indexPath.row].objectForKey("date") as! NSDate
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
		let selectedDate = dateFormatter.stringFromDate(date)

        let color1 = UIColor(red: 174/256.0, green: 187/256.0, blue: 199/256.0, alpha: 0.5)
        let color2 = UIColor(red: 155/256.0, green: 175/256.0, blue: 142/256.0, alpha: 0.5)
        let color3 = UIColor(red: 219/256.0, green: 173/256.0, blue: 114/256.0, alpha: 0.5)
        

		
		if self.announcements[indexPath.row].objectForKey("type") as! String == "Add Event" {
			cell.descriptionLabel.text = "New Event: '\(title)'" + "\n" + "by \(name)"
            cell.backgroundColor = color1
            print(color1)
		}
		else if self.announcements[indexPath.row].objectForKey("type") as! String == "Update Event" {
			cell.descriptionLabel.text = "Update: '\(title)'" + "\n" + "by \(name)"
            cell.backgroundColor = color2
		}
		else if self.announcements[indexPath.row].objectForKey("type") as! String == "Add Note" {
			cell.descriptionLabel.text = "New Note: '\(title)'" + "\n" + "by \(name)"
            cell.backgroundColor = color3
		}

        let dateFormatter1 = NSDateFormatter()
		dateFormatter1.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter1.timeStyle = NSDateFormatterStyle.ShortStyle
		let date1 = dateFormatter1.stringFromDate(self.announcements[indexPath.row].createdAt!)

		cell.timeLabel.text = date1
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		
		let query = PFQuery(className:"Schedule")
		query.whereKey("objectId", equalTo: self.announcements[indexPath.row].objectForKey("eventId")!)
		query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
			
			if object != nil {
				
				selectedEvent.removeAll(keepCapacity: false)
				selectedEvent.append(object!)
				
				let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				
				let controller = storyboard.instantiateViewControllerWithIdentifier("ExistingEventViewController") as! ExistingEventViewController
				
				let nav = UINavigationController(rootViewController: controller)

				self.presentViewController(nav, animated: true, completion: nil)

			} else {
				
				let infoAlert = UIAlertController(title: "Notification", message: "The selected event does not exist anymore", preferredStyle: UIAlertControllerStyle.Alert)
				
				
				infoAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
					
				}))
				
				self.presentViewController(infoAlert, animated: true, completion: nil)
			}
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//		return UITableViewAutomaticDimension
		return 90
	}

	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.announcements.count
	}
	
	func fetchInfo() {
		
		let query = PFQuery(className:"Team_Announcement")
		query.whereKey("teamId", equalTo:selectedTeamId)
		query.addDescendingOrder("createdAt")
		query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
			
			if error == nil {
				for object in objects! {
					
					self.announcements.append(object as! PFObject)
				}
				
				self.resultsTable.reloadData()
			}
		}
	}
	@IBAction func cancelBtn_click(sender: AnyObject) {
		
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

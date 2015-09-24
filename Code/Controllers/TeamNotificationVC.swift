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
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! teamNotificationCell
		
		var name = self.announcements[indexPath.row].objectForKey("name") as! String
		
		var title = self.announcements[indexPath.row].objectForKey("title") as! String
		
		var date = self.announcements[indexPath.row].objectForKey("date") as! NSDate
		
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
		var selectedDate = dateFormatter.stringFromDate(date)

		
		if self.announcements[indexPath.row].objectForKey("type") as! String == "Add Event" {
			
			
			cell.descriptionLabel.text = "\(name) ADDED an event '\(title)'" + "\n" + "for \(selectedDate)"


		}
		if self.announcements[indexPath.row].objectForKey("type") as! String == "Update Event" {
			
			cell.descriptionLabel.text = "\(name) UPDATED an event '\(title)'" + "\n" + "for \(selectedDate)"

			
		}
		if self.announcements[indexPath.row].objectForKey("type") as! String == "Add Note" {
			
			cell.descriptionLabel.text = "\(name) added a NOTE to event '\(title)'" + "\n" + "for \(selectedDate)"
			
		}

		
		
		
		
		var dateFormatter1 = NSDateFormatter()
		dateFormatter1.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter1.timeStyle = NSDateFormatterStyle.ShortStyle
		var date1 = dateFormatter1.stringFromDate(self.announcements[indexPath.row].createdAt!)

		cell.timeLabel.text = date1
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		
		var query = PFQuery(className:"Schedule")
		query.whereKey("objectId", equalTo: self.announcements[indexPath.row].objectForKey("eventId")!)
		query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
			
			if object != nil {
				
				selectedEvent.removeAll(keepCapacity: false)
				selectedEvent.append(object!)
				
				var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
				
				var controller = storyboard.instantiateViewControllerWithIdentifier("ExistingEventViewController") as! ExistingEventViewController
				
				var nav = UINavigationController(rootViewController: controller)

				self.presentViewController(nav, animated: true, completion: nil)

			} else {
				
				var infoAlert = UIAlertController(title: "Notification", message: "The selected event does not exist anymore", preferredStyle: UIAlertControllerStyle.Alert)
				
				
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
		
		var query = PFQuery(className:"Team_Announcement")
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

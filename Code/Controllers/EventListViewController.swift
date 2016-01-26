//
//  EventListViewController.swift
//  
//
//  Created by Jin Seok Park on 2015. 8. 27..
//
//

import UIKit

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var resultsTable: UITableView!
	
	var eventObjectArray = [PFObject]()
	var sortedEventSectionArray = [NSDate]()
	var sortedEventObjectArray = [[PFObject]]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool) {
		
		eventObjectArray.removeAll(keepCapacity: false)
		sortedEventSectionArray.removeAll(keepCapacity: false)
		sortedEventObjectArray.removeAll(keepCapacity: false)

		
		self.queryEvents()

	}
	
	func queryEvents() {
		
		let query = PFQuery(className:"Schedule")
		query.whereKey("teamId", equalTo: selectedTeamId)
		query.addAscendingOrder("startTime")
		query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
			
			for object in objects! {
				self.eventObjectArray.append(object as! PFObject)
			}
			self.resultsTable.reloadData()
			
			self.dateArrange()
		}
	}
	
	func dateArrange() {
	
		var counter = 0

		for var i=0; i<self.eventObjectArray.count; i++ {
			
			
			
			if i == 0 {
				let date = self.eventObjectArray[i].objectForKey("startTime") as! NSDate
				self.sortedEventSectionArray.append(date)
				
				var array = [PFObject]()
				array.append(self.eventObjectArray[i])
				self.sortedEventObjectArray.append(array)
				
			} else {
				

				
				let date1 = self.eventObjectArray[i-1].objectForKey("startTime") as! NSDate
				let date2 = self.eventObjectArray[i].objectForKey("startTime") as! NSDate
				
				let calendar = NSCalendar.currentCalendar()
				let currentComponents = calendar.components([.Year, .Month, .Day], fromDate: date1)
				let previousComponents = calendar.components([.Year, .Month, .Day], fromDate: date2)

				
				if !currentComponents.isEqual(previousComponents) {
					self.sortedEventSectionArray.append(date2)
					counter++
					var array = [PFObject]()
					array.append(self.eventObjectArray[i])
					self.sortedEventObjectArray.append(array)
//					self.sortedEventObjectArray[counter].append(self.eventObjectArray[i])
				} else {
					self.sortedEventObjectArray[counter].append(self.eventObjectArray[i])
				}
			}
		}
		
		
		
		self.resultsTable.reloadData()
		
		
		
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		
		
		return self.sortedEventObjectArray[section].count
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let date = self.sortedEventSectionArray[section]
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
		
		return dateFormatter.stringFromDate(date)
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		selectedEvent.removeAll(keepCapacity: false)
		selectedEvent.append(self.sortedEventObjectArray[indexPath.section][indexPath.row])
		
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("ExistingEventViewController") as! ExistingEventViewController
		
		let nav = UINavigationController(rootViewController: controller)
		
		self.presentViewController(nav, animated: true, completion: nil)

	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! eventListCell
		
		if self.eventObjectArray.count != 0 {
			
//			cell.textLabel!.text = self.sortedEventObjectArray[indexPath.section][indexPath.row].objectForKey("Title") as? String
			
			cell.eventLabel.text = self.sortedEventObjectArray[indexPath.section][indexPath.row].objectForKey("Title") as? String
			
			let startDate = self.sortedEventObjectArray[indexPath.section][indexPath.row].objectForKey("startTime") as? NSDate
			let endDate = self.sortedEventObjectArray[indexPath.section][indexPath.row].objectForKey("endTime") as? NSDate
			
			let dateFormatter = NSDateFormatter()
			
			dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
			
			cell.startTimeLabel.text = dateFormatter.stringFromDate(startDate!)
			cell.endTimeLabel.text = dateFormatter.stringFromDate(endDate!)

		}
		
		return cell
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return self.sortedEventSectionArray.count
	}
	
	
	@IBAction func calendarBtn_click(sender: AnyObject) {
		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	internal override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Portrait
	}
	
	internal override func shouldAutorotate() -> Bool {
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

//
//  CalendarPortraitViewController.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Jin Seok Park on 2015. 8. 28..
//  Copyright (c) 2015년 layer. All rights reserved.
//

import UIKit

var year = 0
var month = 0
var day = 0
var startHour = 0
var nowDate = NSDate()
private let YearUnit = NSCalendarUnit.Year
private let MonthUnit = NSCalendarUnit.Month
private let WeekUnit = NSCalendarUnit.WeekOfMonth
private let WeekdayUnit = NSCalendarUnit.Weekday
private let DayUnit = NSCalendarUnit.Day
private let HourUnit = NSCalendarUnit.Hour
private let MinuteUnit = NSCalendarUnit.Minute
private let SecondUnit = NSCalendarUnit.Second

var components = NSCalendar.currentCalendar().components(YearUnit.union(MonthUnit).union(DayUnit).union(HourUnit).union(MinuteUnit).union(SecondUnit), fromDate: nowDate)

var selectedEvent = [PFObject]()

var monthEvent = [[String]]()


class CalendarPortraitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var menuView: CVCalendarMenuView!
	@IBOutlet weak var calendarView: CVCalendarView!
	@IBOutlet weak var calendarView2: CVCalendarView!
	@IBOutlet weak var resultsTable: UITableView!
	
	@IBOutlet weak var landscapeView: UIView!
	@IBOutlet weak var portraitView: UIView!
	
	var shouldShowDaysOut = true
	var animationFinished = true
	var eventsList:[String] = []
	var startTimesList = [String]()
	var endTimesList = [String]()
	var objectsList = [PFObject]()
	
	let hour = components.hour
	let minutes = components.minute
	
	var isRun = false
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		updateDate()
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
		
	}
	
	override func viewDidAppear(animated: Bool) {
		
		isRun = false
		startHour = hour
		
		refreshResults()
	}
	
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		calendarView.commitCalendarViewUpdate()
		menuView.commitMenuViewUpdate()
		
	}
	
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.None
	}

	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! calendarCell
		
		if self.objectsList.count != 0 {
			cell.eventLabel.text = self.objectsList[indexPath.row].objectForKey("Title") as? String
						
			let startDate = self.objectsList[indexPath.row].objectForKey("startTime") as? NSDate
			let endDate = self.objectsList[indexPath.row].objectForKey("endTime") as? NSDate
			
			let dateFormatter = NSDateFormatter()
			
			dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
			
			cell.startTimeLabel.text = dateFormatter.stringFromDate(startDate!)
			cell.endTimeLabel.text = dateFormatter.stringFromDate(endDate!)
		}
		
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if objectsList.count > 0 {
			
			return objectsList.count
		} else {
			
			return 0
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		return 50
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		
		selectedEvent.removeAll(keepCapacity: false)
		selectedEvent.append(self.objectsList[indexPath.row])
				
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("ExistingEventViewController") as! ExistingEventViewController
		
		let nav = UINavigationController(rootViewController: controller)
		
		self.presentViewController(nav, animated: true, completion: nil)
		
		
	}
	
	
	func updateDate() {
		
		if calendarView == nil {
			year = components.year
			month = components.month
			day = components.day
		} else {
			year = calendarView.presentedDate.year
			month = calendarView.presentedDate.month
			day = calendarView.presentedDate.day
		}
		
		self.checkMonthEvents()
	}
	
	func checkMonthEvents() {
		
		
		
		monthEvent.removeAll(keepCapacity: false)
		
		let query = PFQuery(className:"Schedule")
		query.whereKey("teamId", equalTo: selectedTeamId)
		query.whereKey("Year", equalTo: year)
		query.whereKey("Month", equalTo: month)
		let objects = query.findObjects()
		for object in objects! {

			var array = [String]()
			array.append("\(year)")
			array.append("\(month)")
			let dayNum = object.objectForKey("Day") as! Int
			array.append("\(dayNum)")
			monthEvent.append(array)
			
		}
		
		isRun = true
	}
	
	
	func refreshResults() {
		

		
		selectedEvent.removeAll(keepCapacity: false)
		objectsList.removeAll(keepCapacity: false)
		
		let query:PFQuery = PFQuery(className: "Schedule")
		query.whereKey("teamId", equalTo: selectedTeamId)
		query.whereKey("Year", equalTo: year)
		query.whereKey("Month", equalTo: month)
		query.whereKey("Day", equalTo: day)
		query.findObjectsInBackgroundWithBlock {
			(objects:[AnyObject]?, error:NSError?) -> Void in
			
			if error == nil {
				
				for object in objects! {
					
					let pfObject = object as! PFObject
					
					self.objectsList.append(pfObject)
					
					
					self.resultsTable.reloadData()
					
				}
				self.resultsTable.reloadData()

			}
			
			
		}
		
	}
	
	@IBAction func addBtn_click(sender: AnyObject) {
		
        
        isEditing = false
        
        selectedEvent.removeAll(keepCapacity: false)
        eventParticipantArray.removeAll(keepCapacity: false)
        eventParticipantIdArray.removeAll(keepCapacity: false)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        let controller = storyboard.instantiateViewControllerWithIdentifier("NewEventVC") as! NewEventVC
        let nav: UINavigationController = UINavigationController()
        nav.addChildViewController(controller)
        
        self.presentViewController(nav, animated: true, completion: nil)
				
	}
	
	@IBAction func listBtn_click(sender: AnyObject) {
		
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
		let nav: UINavigationController = UINavigationController()
		nav.addChildViewController(controller)
		
		self.presentViewController(nav, animated: true, completion: nil)

		
		
    }
}

extension CalendarPortraitViewController: CVCalendarViewDelegate
{
	
	func presentationMode() -> CalendarMode {
		return .MonthView
	}
	
	func firstWeekday() -> Weekday {
		return .Sunday
	}
	
	
	func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
		return true
	}
	
	func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
		let day = dayView.date.day
		let month = dayView.date.month
		let year = dayView.date.year
		
		
		if !isRun {
			self.updateDate()
		}
		
		if monthEvent.count != 0 {
			
			for var i=0; i<monthEvent.count; i++ {
				if "\(month)" == monthEvent[i][1] {
					if "\(day)" == monthEvent[i][2] {
						return true
					}
				}
			}
		}
		
		
		return false
	}
	
	
	func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor {
		let day = dayView.date.day

		return UIColor.redColor()
		
	}
	
	func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
		return true
	}
	
	func didSelectDayView(dayView: CVCalendarDayView) {
		let date = dayView.date
		
		year = date.year
		month = date.month
		day = date.day
		
		
		refreshResults()
	}
	
	
	func shouldShowWeekdaysOut() -> Bool {
		return shouldShowDaysOut
	}
	
	func presentedDateUpdated(date: CVDate) {
		if monthLabel.text != date.globalDescription && self.animationFinished {
			let updatedMonthLabel = UILabel()
			updatedMonthLabel.textColor = monthLabel.textColor
			updatedMonthLabel.font = monthLabel.font
			updatedMonthLabel.textAlignment = .Center
			updatedMonthLabel.text = date.globalDescription
			updatedMonthLabel.sizeToFit()
			updatedMonthLabel.alpha = 0
			updatedMonthLabel.center = self.monthLabel.center
			
			let offset = CGFloat(48)
			updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
			updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
			
			UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
				self.animationFinished = false
				self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
				self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
				self.monthLabel.alpha = 0
				
				updatedMonthLabel.alpha = 1
				updatedMonthLabel.transform = CGAffineTransformIdentity
				
				}) { _ in
					
					self.animationFinished = true
					self.monthLabel.frame = updatedMonthLabel.frame
					self.monthLabel.text = updatedMonthLabel.text
					self.monthLabel.transform = CGAffineTransformIdentity
					self.monthLabel.alpha = 1
					updatedMonthLabel.removeFromSuperview()
			}
			
			self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
		}
	}
	
	
}

extension CalendarPortraitViewController: CVCalendarMenuViewDelegate {
	// firstWeekday() has been already implemented.
}




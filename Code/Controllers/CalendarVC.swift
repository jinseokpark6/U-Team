//
//  CalendarVC.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 2015. 6. 26..
//  Copyright (c) 2015년 Jin Seok Park. All rights reserved.
//

import UIKit
import EventKit



class CalendarVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var resultsTable: UITableView!
    
    
    var eventsList:[String] = []
    var startTimesList = [String]()
    var endTimesList = [String]()
	var objectsList = [PFObject]()

    var dayView: CVCalendarDayView!

    
    //current date function
    let hour = components.hour
    let minutes = components.minute
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		selectedEvent.removeAll(keepCapacity: false)
//        
//        dateLabel.text = calendarView.presentedDate.globalDescription
//
//        
//        startHour = hour
//
//        updateDate()
//        
//        refreshResults()
		
//        // 1
//        let eventStore = EKEventStore()
//        
//        // 2
//        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
//        case .Authorized:
//            insertEvent(eventStore)
//        case .Denied:
//            println("Access denied")
//        case .NotDetermined:
//            // 3
//            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
//                {[weak self] (granted: Bool, error: NSError!) -> Void in
//                    if granted {
//                        self!.insertEvent(eventStore)
//                    } else {
//                        println("Access denied")
//                    }
//                })
//        default:
//            println("Case Default")
//        }


        
    }
    
    
//    func insertEvent(store: EKEventStore) {
//        // 1
//        let calendars = store.calendarsForEntityType(EKEntityTypeEvent)
//            as! [EKCalendar]
//        
//        for calendar in calendars {
//            // 2
//            if calendar.title == "ioscreator" {
//                // 3
//                let startDate = NSDate()
//                // 2 hours
//                let endDate = startDate.dateByAddingTimeInterval(2 * 60 * 60)
//                
//                // 4
//                // Create Event
//                var event = EKEvent(eventStore: store)
//                event.calendar = calendar
//                
//                event.title = "New Meeting"
//                event.startDate = startDate
//                event.endDate = endDate
//                
//                // 5
//                // Save Event in Calendar
//                var error: NSError?
//                let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
//                
//                if result == false {
//                    if let theError = error {
//                        println("An error occured \(theError)")
//                    }
//                }
//            }
//        }
//    }
	
    
    func updateDate() {

        year = calendarView.presentedDate.year
        month = calendarView.presentedDate.month
        day = calendarView.presentedDate.day
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:calendarCell = resultsTable.dequeueReusableCellWithIdentifier("Cell") as! calendarCell
        
        
        if self.eventsList.count != 0 {
            cell.eventLabel.text = self.eventsList[indexPath.row]
            cell.startTimeLabel.text = self.startTimesList[indexPath.row]
            cell.endTimeLabel.text = self.endTimesList[indexPath.row]
        }
    
        

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if eventsList.count > 0 {
            
            return eventsList.count
        } else {
            
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 40
    }
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		selectedEvent.append(self.objectsList[indexPath.row])
		self.performSegueWithIdentifier("goToEventVC", sender: self)
	}
    
    func refreshResults() {
        
        eventsList.removeAll(keepCapacity: false)
        startTimesList.removeAll(keepCapacity: false)
        endTimesList.removeAll(keepCapacity: false)

        
        var query:PFQuery = PFQuery(className: "Schedule")
        query.whereKey("Year", equalTo: year)
        query.whereKey("Month", equalTo: month)
        query.whereKey("Day", equalTo: day)
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]?, error:NSError?) -> Void in
            
            if error == nil {
                
                for object in objects! {
					println("\(object)")
					
					var pfObject = object as! PFObject
					
					self.objectsList.append(pfObject)
					
					
                    self.eventsList.append(object.objectForKey("Title") as! String)
                        println(self.eventsList)
                    self.startTimesList.append(object.objectForKey("Start_Time") as! String)
                    self.endTimesList.append(object.objectForKey("End_Time") as! String)
                    
//                    self.resultsTable.reloadData()

                }
            }
            
            self.resultsTable.reloadData()

        }

    }
}





extension CalendarVC: CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        println("\(date.year) is selected!")
        println("\(date.day) is selected!")
        println("\(date.month) is selected!")

        
        year = date.year
        month = date.month
        day = date.day

        
        refreshResults()
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func presentedDateUpdated(date: CVDate) {
        dateLabel.text = calendarView.presentedDate.globalDescription
    }
    
    func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return false
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> UIColor {
        return UIColor.redColor()
    }

}

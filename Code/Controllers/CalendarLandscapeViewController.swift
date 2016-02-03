//
//  Landscape.swift
//  calcal
//
//  Created by Minwoo Shin on 8/4/15.
//  Copyright (c) 2015 Minwoo Shin. All rights reserved.
//

import UIKit

class CalendarLandscapeViewController: UIViewController {
    
    @IBOutlet var monthLabel1: UILabel!
    @IBOutlet var menuViewL: CVCalendarMenuView!
    @IBOutlet var calendarViewL: CVCalendarView!
	
    var shouldShowDaysOut = true
    var animationFinished = true
    
    override func viewDidLoad() {

        super.viewDidLoad()
		
        
        monthLabel1.text = CVDate(date: NSDate()).globalDescription
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarViewL.commitCalendarViewUpdate()
        menuViewL.commitMenuViewUpdate()
   
    }
    
}



extension CalendarLandscapeViewController: CVCalendarViewDelegate
{
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func presentedDateUpdated(date: CVDate) {
		if monthLabel1.text != date.globalDescription && self.animationFinished {
			let updatedMonthLabel = UILabel()
			updatedMonthLabel.textColor = monthLabel1.textColor
			updatedMonthLabel.font = monthLabel1.font
			updatedMonthLabel.textAlignment = .Center
			updatedMonthLabel.text = date.globalDescription
			updatedMonthLabel.sizeToFit()
			updatedMonthLabel.alpha = 0
			updatedMonthLabel.center = self.monthLabel1.center
			
			let offset = CGFloat(48)
			updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
			updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
			
			UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
				self.animationFinished = false
				self.monthLabel1.transform = CGAffineTransformMakeTranslation(0, -offset)
				self.monthLabel1.transform = CGAffineTransformMakeScale(1, 0.1)
				self.monthLabel1.alpha = 0
				
				updatedMonthLabel.alpha = 1
				updatedMonthLabel.transform = CGAffineTransformIdentity
				
				}) { _ in
					
					self.animationFinished = true
					self.monthLabel1.frame = updatedMonthLabel.frame
					self.monthLabel1.text = updatedMonthLabel.text
					self.monthLabel1.transform = CGAffineTransformIdentity
					self.monthLabel1.alpha = 1
					updatedMonthLabel.removeFromSuperview()
			}
			
			self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel1)
		}
    }
	
}

extension CalendarLandscapeViewController: CVCalendarMenuViewDelegate {
    // firstWeekday() has been already implemented.
}






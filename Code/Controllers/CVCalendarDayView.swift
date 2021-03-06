//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarDayView: UIView {
    // MARK: - Public properties
    let weekdayIndex: Int!
    weak var weekView: CVCalendarWeekView!
    
    var date: CVDate!
    var dayLabel: UILabel!
    
    var circleView: CVAuxiliaryView?
    var topMarker: CALayer?
    var dotMarker: CVAuxiliaryView?
    
    var isOut = false
    var isCurrentDay = false
    
    weak var monthView: CVCalendarMonthView! {
        get {
            var monthView: MonthView!
            if let weekView = weekView, let activeMonthView = weekView.monthView {
                monthView = activeMonthView
            }
            
            return monthView
        }
    }
    
    weak var calendarView: CVCalendarView! {
        get {
            var calendarView: CVCalendarView!
            if let weekView = weekView, let activeCalendarView = weekView.calendarView {
                calendarView = activeCalendarView
            }
            
            return calendarView
        }
    }
    
    override var frame: CGRect {
        didSet {
            if oldValue != frame {
                circleView?.setNeedsDisplay()
                topMarkerSetup()
            }
        }
    }
    
    override var hidden: Bool {
        didSet {
            userInteractionEnabled = hidden ? false : true
        }
    }
    
    // MARK: - Initialization
    
    init(weekView: CVCalendarWeekView, frame: CGRect, weekdayIndex: Int) {
        self.weekView = weekView
        self.weekdayIndex = weekdayIndex
        
        super.init(frame: frame)
        
        date = dateWithWeekView(weekView, andWeekIndex: weekdayIndex)
        
        labelSetup()
        setupDotMarker()
        topMarkerSetup()
        
        if !calendarView.shouldShowWeekdaysOut && isOut {
            hidden = true
        }
    }
    
    func dateWithWeekView(weekView: CVCalendarWeekView, andWeekIndex index: Int) -> CVDate {
        func hasDayAtWeekdayIndex(weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            for key in weekdaysDictionary.keys {
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        
        var day: Int!
        let weekdaysIn = weekView.weekdaysIn
        
        if let weekdaysOut = weekView.weekdaysOut {
            if hasDayAtWeekdayIndex(weekdayIndex, weekdaysDictionary: weekdaysOut) {
                isOut = true
                day = weekdaysOut[weekdayIndex]![0]
            } else if hasDayAtWeekdayIndex(weekdayIndex, weekdaysDictionary: weekdaysIn!) {
                day = weekdaysIn![weekdayIndex]![0]
            }
        } else {
            day = weekdaysIn![weekdayIndex]![0]
        }
        
        if day == monthView.currentDay && !isOut {
            let dateRange = Manager.dateRange(monthView.date)
            let currentDateRange = Manager.dateRange(NSDate())
            
            if dateRange.month == currentDateRange.month && dateRange.year == currentDateRange.year {
                isCurrentDay = true
            }
        }
        
        
        let dateRange = Manager.dateRange(monthView.date)
        let year = dateRange.year
        let week = weekView.index + 1
        var month = dateRange.month
        
        if isOut {
            day > 20 ? month-- : month++
        }
        
        return CVDate(day: day, month: month, week: week, year: year)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews setup

extension CVCalendarDayView {
    func labelSetup() {
        let appearance = calendarView.appearance
        
        dayLabel = UILabel()
        dayLabel!.text = String(date.day)
        dayLabel!.textAlignment = NSTextAlignment.Center
        dayLabel!.frame = bounds
        
        var font = appearance.dayLabelWeekdayFont
        var color: UIColor?
        
        if isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            let coordinator = calendarView.coordinator
            if coordinator.selectedDayView == nil {
                let touchController = calendarView.touchController
                touchController.receiveTouchOnDayView(self)
                calendarView.didSelectDayView(self)
            } else {
                color = appearance.dayLabelPresentWeekdayTextColor
                if appearance.dayLabelPresentWeekdayInitallyBold! {
                    font = appearance.dayLabelPresentWeekdayBoldFont
                } else {
                    font = appearance.dayLabelPresentWeekdayFont
                }
            }
            
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        if color != nil && font != nil {
            dayLabel!.textColor = color!
            dayLabel!.font = font
        }
        
        addSubview(dayLabel!)
    }
    
    // TODO: Make this widget customizable
    func topMarkerSetup() {
        safeExecuteBlock({
            func createMarker() {
                let height = CGFloat(0.5)
                let layer = CALayer()
                layer.borderColor = UIColor.grayColor().CGColor
                layer.borderWidth = height
                layer.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), height)

                self.topMarker = layer
                self.layer.addSublayer(self.topMarker!)
            }
            
            if let delegate = self.calendarView.delegate {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                if let shouldDisplay = delegate.topMarker?(shouldDisplayOnDayView: self) where shouldDisplay {
                    createMarker()
                }
            } else {
                if self.topMarker == nil {
                    createMarker()
                } else {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                    createMarker()
                }
            }
        }, collapsingOnNil: false, withObjects: weekView, weekView.monthView, weekView.monthView)
    }
    
    func setupDotMarker() {
        if let dotMarker = dotMarker {
            self.dotMarker!.removeFromSuperview()
            self.dotMarker = nil
        }
        
        if let delegate = calendarView.delegate {
            if let shouldShow = delegate.dotMarker?(shouldShowOnDayView: self) where shouldShow {
                let color = isOut ? .grayColor() : delegate.dotMarker?(colorOnDayView: self)
                let width: CGFloat = 13
                let height: CGFloat = 13
                var yOffset = bounds.height / 5
                if let y = delegate.dotMarker?(moveOffsetOnDayView: self) {
                    yOffset = y
                }
                
                let x = frame.width / 2
                let y = CGRectGetMidY(frame) + yOffset
                let markerFrame = CGRectMake(0, 0, width, height)
                
                dotMarker = CVAuxiliaryView(dayView: self, rect: markerFrame, shape: .Circle)
                dotMarker!.fillColor = color
                dotMarker!.center = CGPointMake(x, y)
                insertSubview(dotMarker!, atIndex: 0)
                
                let coordinator = calendarView.coordinator
                if self == coordinator.selectedDayView {
                    moveDotMarkerBack(false, coloring: false)
                }
                
                dotMarker!.setNeedsDisplay()
            }
        }
    }
}

// MARK: - Dot marker movement

extension CVCalendarDayView {
    func moveDotMarkerBack(unwinded: Bool, var coloring: Bool) {
        if let calendarView = calendarView, let dotMarker = dotMarker {
            var shouldMove = true
            if let delegate = calendarView.delegate, let move = delegate.dotMarker?(shouldMoveOnHighlightingOnDayView: self) where !move {
                shouldMove = move
            }
            
            func colorMarker() {
                if let delegate = calendarView.delegate {
                    let appearance = calendarView.appearance
                    let frame = dotMarker.frame
                    var color: UIColor?
                    if unwinded {
                        if let myColor = delegate.dotMarker?(colorOnDayView: self) {
                            color = (isOut) ? appearance.dayLabelWeekdayOutTextColor : myColor
                        }
                    } else {
                        color = appearance.dotMarkerColor
                    }
                    
                    dotMarker.fillColor = color
                    dotMarker.setNeedsDisplay()
                }
                
            }
            
            func moveMarker() {
                var transform: CGAffineTransform!
                if let circleView = circleView {
                    let point = pointAtAngle(CGFloat(-90).toRadians(), withinCircleView: circleView)
                    let spaceBetweenDotAndCircle = CGFloat(0.5)
                    let offset = point.y - dotMarker.frame.origin.y - dotMarker.bounds.height/2 + spaceBetweenDotAndCircle
                    transform = unwinded ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, offset)
                    
                    if dotMarker.center.y + offset > CGRectGetMaxY(frame) {
                        coloring = true
                    }
                } else {
                    transform = CGAffineTransformIdentity
                }
                
                if !coloring {
                    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        dotMarker.transform = transform
                        }, completion: { _ in
                            
                    })
                } else {
                    moveDotMarkerBack(unwinded, coloring: coloring)
                }
            }
            
            if shouldMove && !coloring {
                moveMarker()
            } else {
                colorMarker()
            }
        }
        
    }
}


// MARK: - Circle geometry

extension CGFloat {
    func toRadians() -> CGFloat {
        return CGFloat(self) * CGFloat(M_PI / 180)
    }
    
    func toDegrees() -> CGFloat {
        return CGFloat(180/M_PI) * self
    }
}

extension CVCalendarDayView {
    func pointAtAngle(angle: CGFloat, withinCircleView circleView: UIView) -> CGPoint {
        let radius = circleView.bounds.width / 2
        let xDistance = radius * cos(angle)
        let yDistance = radius * sin(angle)
        
        let center = circleView.center
        let x = floor(cos(angle)) < 0 ? center.x - xDistance : center.x + xDistance
        let y = center.y - yDistance
        
        let result = CGPointMake(x, y)
        
        return result
    }
    
    func moveView(view: UIView, onCircleView circleView: UIView, fromAngle angle: CGFloat, toAngle endAngle: CGFloat, straight: Bool) {
        let condition = angle > endAngle ? angle > endAngle : angle < endAngle
        if straight && angle < endAngle || !straight && angle > endAngle {
            UIView.animateWithDuration(pow(10, -1000), delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                let angle = angle.toRadians()
                view.center = self.pointAtAngle(angle, withinCircleView: circleView)
            }) { _ in
                let speed = CGFloat(750).toRadians()
                let newAngle = straight ? angle + speed : angle - speed
                self.moveView(view, onCircleView: circleView, fromAngle: newAngle, toAngle: endAngle, straight: straight)
            }
        }
    }
}

// MARK: - Day label state management

extension CVCalendarDayView {
    func setDayLabelHighlighted() {
        let appearance = calendarView.appearance
        
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        
        if isCurrentDay {
            dayLabel?.textColor = appearance.dayLabelPresentWeekdayHighlightedTextColor!
            dayLabel?.font = appearance.dayLabelPresentWeekdayHighlightedFont
            backgroundColor = appearance.dayLabelPresentWeekdayHighlightedBackgroundColor
            backgroundAlpha = appearance.dayLabelPresentWeekdayHighlightedBackgroundAlpha
        } else {
            dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
            dayLabel?.font = appearance.dayLabelWeekdayHighlightedFont
            backgroundColor = appearance.dayLabelWeekdayHighlightedBackgroundColor
            backgroundAlpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
        }
        
        if let circleView = circleView {
            circleView.fillColor = backgroundColor
            circleView.alpha = backgroundAlpha
            circleView.setNeedsDisplay()
        } else {
            circleView = CVAuxiliaryView(dayView: self, rect: dayLabel.bounds, shape: .Rect)
            circleView!.fillColor = circleView!.defaultFillColor
            circleView!.alpha = backgroundAlpha
            insertSubview(circleView!, atIndex: 0)
        }
        
        moveDotMarkerBack(false, coloring: false)
    
    }
    
    func setDayLabelUnhighlightedDismissingState(removeViews: Bool) {
        let appearance = calendarView.appearance
        
        var color: UIColor?
        if isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        var font: UIFont?
        if self.isCurrentDay {
            if appearance.dayLabelPresentWeekdayInitallyBold! {
                font = appearance.dayLabelPresentWeekdayBoldFont
            } else {
                font = appearance.dayLabelWeekdayFont
            }
        } else {
            font = appearance.dayLabelWeekdayFont
        }
        
        dayLabel?.textColor = color
        dayLabel?.font = font
        
        moveDotMarkerBack(true, coloring: false)
        
        if removeViews {
            circleView?.removeFromSuperview()
            circleView = nil
        }
    }
    
    func setDayLabelSelected() {
        let appearance = calendarView.appearance
        
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        
        if isCurrentDay {
            dayLabel?.textColor = appearance.dayLabelPresentWeekdaySelectedTextColor!
            dayLabel?.font = appearance.dayLabelPresentWeekdaySelectedFont
            backgroundColor = appearance.dayLabelPresentWeekdaySelectedBackgroundColor
            backgroundAlpha = appearance.dayLabelPresentWeekdaySelectedBackgroundAlpha
        } else {
            dayLabel?.textColor = appearance.dayLabelWeekdaySelectedTextColor
            dayLabel?.font = appearance.dayLabelWeekdaySelectedFont
            backgroundColor = appearance.dayLabelWeekdaySelectedBackgroundColor
            backgroundAlpha = appearance.dayLabelWeekdaySelectedBackgroundAlpha
        }
        
        if let circleView = circleView {
            circleView.fillColor = backgroundColor
            circleView.alpha = backgroundAlpha
            circleView.setNeedsDisplay()
        } else {
            circleView = CVAuxiliaryView(dayView: self, rect: dayLabel.bounds, shape: .Circle)
            circleView!.fillColor = backgroundColor
            circleView!.alpha = backgroundAlpha
            circleView?.setNeedsDisplay()
            insertSubview(circleView!, atIndex: 0)
        }
        
        moveDotMarkerBack(false, coloring: false)
    }
    
    func setDayLabelDeselectedDismissingState(removeViews: Bool) {
        setDayLabelUnhighlightedDismissingState(removeViews)
    }

}

// MARK: - Content reload

extension CVCalendarDayView {
    func reloadContent() {
        setupDotMarker()
        dayLabel?.frame = bounds
        
        let shouldShowDaysOut = calendarView.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if isOut {
                hidden = true
            }
        } else {
            if isOut {
                hidden = false
            }
        }
        
        if circleView != nil {
            setDayLabelDeselectedDismissingState(true)
            setDayLabelSelected()
        }
    }
}

// MARK: - Safe execution

extension CVCalendarDayView {
    func safeExecuteBlock(block: Void -> Void, collapsingOnNil collapsing: Bool, withObjects objects: AnyObject?...) {
        for object in objects {
            if object == nil {
                if collapsing {
                    fatalError("Object { \(object) } must not be nil!")
                } else {
                    return
                }
            }
        }
        
        block()
    }
}

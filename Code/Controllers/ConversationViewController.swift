import UIKit

var isNew = false

class ConversationViewController: ATLConversationViewController, ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate, ATLParticipantTableViewControllerDelegate {
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    var usersArray: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.addressBarController.delegate = self
        
        // Setup the dateformatter used by the dataSource.
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

        self.configureUI()
		
		self.hideBottomBar()
		
		if !isNew {
			let title = NSLocalizedString("Details", comment: "")
			let detailsItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("detailsButtonTapped:"))
			self.navigationItem.setRightBarButtonItem(detailsItem, animated: false)
		}

    }
	
	override func viewDidAppear(animated: Bool) {
		
		isModal = true
		

	}
	
	// MARK - hides Bottom Bar
	
	func hideBottomBar() {
		let tabBar = self.tabBarController?.tabBar
		let parent = tabBar?.superview
		let content = parent?.subviews[0]
		let window = parent?.superview
		
		var tabFrame = tabBar!.frame
		tabFrame.origin.y = CGRectGetMaxY(window!.bounds)
		tabBar!.frame = tabFrame
        if let content = content {
            content.frame = window!.bounds
        }
	}

    // MARK - UI Configuration methods

    func configureUI() {
        ATLOutgoingMessageCollectionViewCell.appearance().messageTextColor = UIColor.whiteColor()
    }

    // MARK - ATLConversationViewControllerDelegate methods

    func conversationViewController(viewController: ATLConversationViewController, didSendMessage message: LYRMessage) {
        print("Message sent!")
    }

    func conversationViewController(viewController: ATLConversationViewController, didFailSendingMessage message: LYRMessage, error: NSError?) {
        print("Message failed to sent with error: \(error)")
    }

    func conversationViewController(viewController: ATLConversationViewController, didSelectMessage message: LYRMessage) {
        print("Message selected")
    }

    // MARK - ATLConversationViewControllerDataSource methods

    func conversationViewController(conversationViewController: ATLConversationViewController, participantForIdentifier participantIdentifier: String) -> ATLParticipant? {
		
		let user: PFUser? = UserManager.sharedManager.cachedUserForUserID(participantIdentifier)
		
		var found = false
		for var i=0; i<participantArray.count; i++ {
			if user == participantArray[i] {
				found = true
				break
			}
		}
		if found == false {
			participantArray.append(user)
		}

        if (participantIdentifier == PFUser.currentUser()!.objectId!) {
			participantArray.append(user)
            return PFUser.currentUser()!
        }
		
        if (user == nil) {
            UserManager.sharedManager.queryAndCacheUsersWithIDs([participantIdentifier]) { (participants: NSArray?, error: NSError?) -> Void in
                if (participants?.count > 0 && error == nil) {
                    self.addressBarController.reloadView()
                    // TODO: Need a good way to refresh all the messages for the refreshed participants...
                    self.reloadCellsForMessagesSentByParticipantWithIdentifier(participantIdentifier)
                } else {
                    print("Error querying for users: \(error)")
                }
            }
        }
        return user
    }

    func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfDate date: NSDate) -> NSAttributedString? {
        let attributes: NSDictionary = [ NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.grayColor() ]
        return NSAttributedString(string: self.dateFormatter.stringFromDate(date), attributes: attributes as? [String : AnyObject])
    }

    func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject:AnyObject]) -> NSAttributedString? {
        if (recipientStatus.count == 0) {
            return nil
        }
        let mergedStatuses: NSMutableAttributedString = NSMutableAttributedString()

        let recipientStatusDict = recipientStatus as NSDictionary
        let allKeys = recipientStatusDict.allKeys as NSArray
        allKeys.enumerateObjectsUsingBlock { participant, _, _ in
            let participantAsString = participant as! String
            if (participantAsString == self.layerClient.authenticatedUserID) {
                return
            }

            let checkmark: String = "✔︎"
            var textColor: UIColor = UIColor.lightGrayColor()
            let status: LYRRecipientStatus! = LYRRecipientStatus(rawValue: Int(recipientStatusDict[participantAsString]!.unsignedIntegerValue))

            switch status! {
            case .Sent:
                textColor = UIColor.lightGrayColor()
            case .Delivered:
                textColor = UIColor.orangeColor()
            case .Read:
                textColor = UIColor.greenColor()
            default:
                textColor = UIColor.lightGrayColor()
            }
            let statusString: NSAttributedString = NSAttributedString(string: checkmark, attributes: [NSForegroundColorAttributeName: textColor])
            mergedStatuses.appendAttributedString(statusString)
        }
        return mergedStatuses;
    }

    // MARK - ATLAddressBarViewController Delegate methods methods

    override func addressBarViewController(addressBarViewController: ATLAddressBarViewController, didTapAddContactsButton addContactsButton: UIButton) {
		
		UserManager.sharedManager.queryForTeamUsersWithCompletion(selectedTeamId, includeCurrUser: false) { (users: NSArray?, error: NSError?) in
			if error == nil {
				let participants = NSSet(array: users as! [PFUser]) as Set<NSObject>
				let controller = ParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
				controller.delegate = self
				isModal = true
				print(controller)
				
				let nav = UINavigationController(rootViewController: controller)

				self.presentViewController(nav, animated: true, completion: nil)
				print("HI")
			} else {
				print("Error querying for All Users: \(error)")
			}
		}
    }
	

	override func addressBarViewControllerDidSelectWhileDisabled(addressBarViewController: ATLAddressBarViewController!, didTapBarWhileDisabled addContactsButton: UIButton!) {
		
		print("hi")
		self.detailsButtonTapped(self)
	}
	
    override func addressBarViewController(addressBarViewController: ATLAddressBarViewController, searchForParticipantsMatchingText searchText: String, completion: (([AnyObject]) -> Void)?) {
		UserManager.sharedManager.queryTeamForUserWithName(searchText, teamId:selectedTeamId) { (participants: NSArray?, error: NSError?) in
            if (error == nil) {
                if let callback = completion {
                    callback(participants! as [AnyObject])
                }
            } else {
                print("Error search for participants: \(error)")
            }
        }
    }

    // MARK - ATLParticipantTableViewController Delegate Methods

    func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
        print("participant: \(participant)")
        self.addressBarController.selectParticipant(participant)
        print("selectedParticipants: \(self.addressBarController.selectedParticipants)")
//        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
	
	func participantTableViewController(participantTableViewController: ATLParticipantTableViewController!, didDeselectParticipant participant: ATLParticipant!) {
		
//		self.addressBarController.
	}

    func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSearchWithString searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
        UserManager.sharedManager.queryTeamForUserWithName(searchText, teamId:selectedTeamId) { (participants, error) in
            if (error == nil) {
                if let callback = completion {
                    callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
                }
            } else {
                print("Error search for participants: \(error)")
            }
        }
    }
	
	
	
	func detailsButtonTapped(sender: AnyObject) {

		
		isEvent = false
		
		print("APRSDF ARRAY: \(participantArray)")
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		let controller = storyboard.instantiateViewControllerWithIdentifier("ConversationDetailVC") as! ConversationDetailVC
		
		self.navigationController!.pushViewController(controller, animated: true)


		
	}
	
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
	
	internal override func shouldAutorotate() -> Bool {
		return false
	}


}

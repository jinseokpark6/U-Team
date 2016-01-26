import UIKit


//var selectedConversation: LYRConversation = LYRConversation()

class ConversationListViewController: ATLConversationListViewController, ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
		
		let tabBar = self.tabBarController?.tabBar
		
		for var i=0; i<tabBar!.items?.count; i++ {
            if let tabBarItem = tabBar!.items?[i] {
                tabBarItem.title = nil
            }
			//tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
		}

		
        self.navigationController!.navigationBar.tintColor = ATLBlueColor()
        
//        let title = NSLocalizedString("Logout", comment: "")
//        let logoutItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logoutButtonTapped:"))
//        self.navigationItem.setLeftBarButtonItem(logoutItem, animated: false)

        let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: Selector("composeButtonTapped:"))
		composeItem.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(composeItem, animated: false)
		
		
		self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
	

	override func viewDidAppear(animated: Bool) {
		
		self.showBottomBar()
		participantArray.removeAll(keepCapacity: false)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK - shows Bottom Bar
	
	func showBottomBar() {
		let tabBar = self.tabBarController?.tabBar
		let parent = tabBar?.superview
		var content = parent?.subviews[0]
		let window = parent?.superview
		
		var tabFrame = tabBar!.frame
		tabFrame.origin.y = CGRectGetMaxY(window!.bounds) - CGRectGetHeight(tabBar!.frame)
		tabBar!.frame = tabFrame
		
	}

	
    // MARK - ATLConversationListViewControllerDelegate Methods

    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSelectConversation conversation:LYRConversation) {
        let unresolvedParticipants: NSArray = UserManager.sharedManager.unCachedUserIDsFromParticipants(Array(conversation.participants))
        if unresolvedParticipants.count == 0 {
			
			participantArray.removeAll(keepCapacity: false)

			print("selected")
			
            let controller = ConversationViewController(layerClient: self.layerClient)
            controller.conversation = conversation
//			selectedConversation = conversation
            controller.displaysAddressBar = true
//			selectedConversation = conversation

			
			
			self.navigationController!.pushViewController(controller, animated: true)
			
			isNew = false
        }
    }

    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didDeleteConversation conversation: LYRConversation, deletionMode: LYRDeletionMode) {
        print("Conversation deleted")
    }

    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didFailDeletingConversation conversation: LYRConversation, deletionMode: LYRDeletionMode, error: NSError?) {
        print("Failed to delete conversation with error: \(error)")
    }

    func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSearchForText searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
        UserManager.sharedManager.queryTeamForUserWithName(searchText,teamId: selectedTeamId) { (participants: NSArray?, error: NSError?) in
            if error == nil {
                if let callback = completion {
                    callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
                }
            } else {
                if let callback = completion {
                    callback(nil)
                }
                print("Error searching for Users by name: \(error)")
            }
        }
    }

    // MARK - ATLConversationListViewControllerDataSource Methods

	

	
    func conversationListViewController(conversationListViewController: ATLConversationListViewController, titleForConversation conversation: LYRConversation) -> String {
        if conversation.metadata["title"] != nil {
            return conversation.metadata["title"] as! String
        } else {
            let listOfParticipant = Array(conversation.participants)

            let unresolvedParticipants: NSArray = UserManager.sharedManager.unCachedUserIDsFromParticipants(listOfParticipant)
            let resolvedNames: NSArray = UserManager.sharedManager.resolvedNamesFromParticipants(listOfParticipant)
            
            if (unresolvedParticipants.count > 0) {
                UserManager.sharedManager.queryAndCacheUsersWithIDs(unresolvedParticipants as! [String]) { (participants: NSArray?, error: NSError?) in
                    if (error == nil) {
                        if (participants?.count > 0) {
                            self.reloadCellForConversation(conversation)
                        }
                    } else {
                        print("Error querying for Users: \(error)")
                    }
                }
            }
            
            if (resolvedNames.count > 0 && unresolvedParticipants.count > 0) {
                let resolved = resolvedNames.componentsJoinedByString(", ")
                return "\(resolved) and \(unresolvedParticipants.count) others"
            } else if (resolvedNames.count > 0 && unresolvedParticipants.count == 0) {
                return resolvedNames.componentsJoinedByString(", ")
            } else {
                return "Conversation with \(conversation.participants.count) users..."
            }
        }
    }

    // MARK - Actions

    func composeButtonTapped(sender: AnyObject) {
        let controller = ConversationViewController(layerClient: self.layerClient)
        controller.displaysAddressBar = true
        self.navigationController!.pushViewController(controller, animated: true)
		
		isNew = true
    }

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Portrait
	}
	
	override func shouldAutorotate() -> Bool {
		return false
	}
}

//extension UINavigationController {
//	public override func supportedInterfaceOrientations() -> Int {
//		return visibleViewController.supportedInterfaceOrientations()
//	}
//}
//

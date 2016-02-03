import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    var layerClient: LYRClient!
    
    // MARK TODO: Before first launch, update LayerAppIDString, ParseAppIDString or ParseClientKeyString values
    // TODO:If LayerAppIDString, ParseAppIDString or ParseClientKeyString are not set, this app will crash"
    let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/3fe22e64-3b83-11e5-bf76-2d4d7f0072d6")
	
	
    let ParseAppIDString: String = "8FCgK7xgSL8K1q7gxQVTPGcondOe7U9TvRFX5gNI"
    let ParseClientKeyString: String = "bIX7LFCtnoVKG7v5tnOrMtUG7kDyn4vOk6AO3G8c"
    
    //Please note, You must set `LYRConversation *conversation` as a property of the ViewController.
    var conversation: LYRConversation!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupParse()
        setupLayer()
		
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Avenir Next", size: 25) as! AnyObject]

		
		UINavigationBar.appearance().barTintColor = UIColor(red: 69.0/255, green: 175.0/255, blue: 220.0/255, alpha: 1)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		
    
		
		
		// Badge Count
		let badgeCount = application.applicationIconBadgeNumber
        
		application.applicationIconBadgeNumber = 0
				
		
		//
		
		let controller = storyboard.instantiateInitialViewController() as! ViewController
        controller.layerClient = layerClient

        self.window!.rootViewController = UINavigationController(rootViewController: controller)

        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
		
		
		// Register for Push Notitications
		if application.applicationState != UIApplicationState.Background {
			// Track an app open here if we launch with a push, unless
			// "content_available" was used to trigger a background push (introduced in iOS 7).
			// In that case, we skip tracking here to avoid double counting the app-open.
			
			let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
			let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
			var pushPayload = false
			if let options = launchOptions {
				pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
			}
			if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
				
				PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground([NSObject : AnyObject]?(), block: { (Bool, NSError) -> Void in
					
				})
			}
		}
		if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
			let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
			application.registerUserNotificationSettings(settings)
			application.registerForRemoteNotifications()
			
			
		} else {
            let types: UIRemoteNotificationType = [.Badge, .Alert, .Sound]
			application.registerForRemoteNotificationTypes(types)
		}

		
		
		
		
        return true
    }
	
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("Successfully added installation")
            }
        }
        
        // Send device token to Layer so Layer can send pushes to this device.
        // For more information about Push, check out:
        // https://developer.layer.com/docs/ios/guides#push-notification
        assert(self.layerClient != nil, "The Layer client has not been initialized!")
        do {
            try self.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
            print("Application did register for remote notifications: \(deviceToken)")
        } catch let error as NSError {
            print("Failed updating device token with error: \(error)")
        }

	}
	
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		
		
		let success = self.layerClient.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) -> Void in
			
			if (changes != nil) {
				if [changes.count] != nil {
//					var message = self.messageFromRemoteNotification(userInfo)
					completionHandler(UIBackgroundFetchResult.NewData)
				} else {
					completionHandler(UIBackgroundFetchResult.NoData)
				}
			} else {
				completionHandler(UIBackgroundFetchResult.Failed)
			}
		})
		
		if !success {
			completionHandler(UIBackgroundFetchResult.NoData)
		}
	}

	func messageFromRemoteNotification(remoteNotification:NSDictionary) -> LYRMessage {
		
		let LQSPushMessageIdentifierKeyPath:NSString = "layer.message_identifier"
		
		// Retrieve message URL from Push Notification
		let messageURL = NSURL(string: "", relativeToURL: remoteNotification.valueForKeyPath(LQSPushMessageIdentifierKeyPath as String) as? NSURL)
		
		// Retrieve LYRMessage from Message URL
		let query = LYRQuery(queryableClass: LYRMessage.self)
		query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsIn, value: NSSet(object: messageURL!))
		
		var messages: NSOrderedSet = NSOrderedSet()
        
        do {
            try messages = self.layerClient.executeQuery(query)
            
            if messages.count != 0 {
                print("Query contains \(messages.count) messages")
                let message = messages.firstObject as! LYRMessage
                let messagePart = message.parts[0] as! LYRMessagePart
                print("Pushed Message Contents: \(NSString(data: messagePart.data, encoding: NSUTF8StringEncoding)))")
            }

        } catch let error as NSError {
            print("Failed receiving message with error: \(error)")
        }

		
		return messages.firstObject as! LYRMessage
	}
	
	
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		if error.code == 3010 {
			print("Push notifications are not supported in the iOS Simulator.")
		} else {
			print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
		}
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		
		NSNotificationCenter.defaultCenter().postNotificationName("getMessage", object: nil)
		
		PFPush.handlePush(userInfo)
		if application.applicationState == UIApplicationState.Inactive {
			PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground([NSObject : AnyObject]?(), block: { (Bool, NSError) -> Void in
				
			})
		}
		
	}


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupParse() {
        // Enable Parse local data store for user persistence
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseAppIDString, clientKey: ParseClientKeyString)
        
        // Set default ACLs
        let defaultACL: PFACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
    }
    
    func setupLayer() {
        layerClient = LYRClient(appID: LayerAppIDString)
        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as! Set<NSObject>
    }
	
}


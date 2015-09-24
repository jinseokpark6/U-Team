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
		
		
		UINavigationBar.appearance().barTintColor = UIColor(red: 69.0/255, green: 175.0/255, blue: 220.0/255, alpha: 1)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		
		
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
			
		
		
		var controller = storyboard.instantiateInitialViewController() as! ViewController
		println("a")
        controller.layerClient = layerClient
		println("b")

        self.window!.rootViewController = UINavigationController(rootViewController: controller)
		println("c")

        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
		
		
		//push notification
		
		
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
			let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
			let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
			application.registerUserNotificationSettings(settings)
			application.registerForRemoteNotifications()
			
			
		} else {
			let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
			application.registerForRemoteNotificationTypes(types)
		}

		
		
		
		
        return true
    }
	
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		let error: NSErrorPointer = NSErrorPointer()
		let success = self.layerClient.updateRemoteNotificationDeviceToken(deviceToken,error:error)
		
		if (success) {
			println("Application did register for remote notifications")
		} else {
			println("Error updating Layer device token for push: \(error)")
		}
		
		let installation = PFInstallation.currentInstallation()
		installation.setDeviceTokenFromData(deviceToken)
		installation.saveInBackgroundWithBlock { (success, error) -> Void in
			if success {
				println("Successfully added installation")
			}
		}
	}
	
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		
		var error: NSError
		
		var success = self.layerClient.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) -> Void in
			
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
		var messageURL = NSURL(string: "", relativeToURL: remoteNotification.valueForKeyPath(LQSPushMessageIdentifierKeyPath as String) as? NSURL)
		
		// Retrieve LYRMessage from Message URL
		var query = LYRQuery(queryableClass: LYRMessage.self)
		query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsIn, value: NSSet(object: messageURL!))
		
		var error:NSErrorPointer = nil
		var messages:NSOrderedSet = self.layerClient.executeQuery(query, error: error)
		if messages.count != 0 {
			println("Query contains \(messages.count) messages")
			var message = messages.firstObject as! LYRMessage
			var messagePart = message.parts[0] as! LYRMessagePart
			println("Pushed Message Contents: \(NSString(data: messagePart.data, encoding: NSUTF8StringEncoding)))")
		} else {
			println("Query failed with error \(error)")
		}
		
		return messages.firstObject as! LYRMessage
	}
	
	
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		if error.code == 3010 {
			println("Push notifications are not supported in the iOS Simulator.")
		} else {
			println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
		}
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		
		NSNotificationCenter.defaultCenter().postNotificationName("getMessage", object: nil)
		
		PFPush.handlePush(userInfo)
		println("userinfo : \(userInfo)")
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
        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as Set<NSObject>
    }
	
}


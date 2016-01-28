import UIKit

var isLogout = false
var isSignUp = false

class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    var layerClient: LYRClient!
    var logInViewController: PFLogInViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		
		isLogout = false
		
        if (PFUser.currentUser() != nil) {
			self.loginLayer()
            return
        }
        
        // No user logged in
        let signupButtonBackgroundImage: UIImage = getImageWithColor(ATLBlueColor(), size: CGSize(width: 10.0, height: 10.0))
        
        // Create the log in view controller
        self.logInViewController = PFLogInViewController()
		
		self.logInViewController.view.backgroundColor = UIColor(red: 69.0/255, green: 175.0/255, blue: 220.0/255, alpha: 1)

		self.logInViewController.fields = ([.UsernameAndPassword,
                                            .LogInButton,
                                            .SignUpButton,
                                            .PasswordForgotten])
        self.logInViewController.delegate = self
        let logoImageView: UIImageView = UIImageView(image: UIImage(named:"UTeamLogoBlank"))
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.logInViewController.logInView!.logInButton?.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.logInViewController.logInView!.signUpButton?.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.logInViewController.logInView!.passwordForgottenButton?.setTitleColor(UIColor.yellowColor(), forState: UIControlState.Normal)
        self.logInViewController.logInView!.logo = logoImageView
		
        // Create the sign up view controller
        let signUpViewController: PFSignUpViewController = PFSignUpViewController()
		signUpViewController.view.backgroundColor = UIColor(red: 69.0/255, green: 175.0/255, blue: 220.0/255, alpha: 1)
        signUpViewController.signUpView!.signUpButton!.setBackgroundImage(nil, forState: UIControlState.Normal)
        self.logInViewController.signUpController = signUpViewController
        signUpViewController.delegate = self
        let signupImageView: UIImageView = UIImageView(image: UIImage(named:"UTeamLogoBlank"))
        signupImageView.contentMode = UIViewContentMode.ScaleAspectFit
        signUpViewController.signUpView!.logo = signupImageView

        self.presentViewController(self.logInViewController,  animated: true, completion:nil)
    }

    // MARK - PFLogInViewControllerDelegate

    // Sent to the delegate to determine whether the log in request should be submitted to the server.
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username:String, password: String) -> Bool {
        if (!username.isEmpty && !password.isEmpty) {
            return true // Begin login process
        }
        
        let title = NSLocalizedString("Missing Information", comment: "")
        let message = NSLocalizedString("Make sure you fill out all of the information!", comment: "")
        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        
        return false // Interrupt login process
    }

    // Sent to the delegate when a PFUser is logged in.
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
		
		isSignUp = false
		
        self.dismissViewControllerAnimated(true, completion: nil)
		print("HI")
        self.loginLayer()
    }

    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        if let description = error?.localizedDescription {
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            UIAlertView(title: description, message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        }
        print("Failed to log in...")
    }

    // MARK: - PFSignUpViewControllerDelegate

    // Sent to the delegate to determine whether the sign up request should be submitted to the server.
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        var informationComplete: Bool = true
        
        // loop through all of the submitted data
        for (key, _) in info {
            if let field = info[key] as? String {
                if field.isEmpty {
                    informationComplete = false
                    break
                }
            }
        }
        
        // Display an alert if a field wasn't completed
        if (!informationComplete) {
            let title = NSLocalizedString("Signup Failed", comment: "")
            let message = NSLocalizedString("All fields are required", comment: "")
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        }
        
        return informationComplete;
    }

    // Sent to the delegate when a PFUser is signed up.
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
		
		isSignUp = true
		
        self.dismissViewControllerAnimated(true, completion: nil)
        self.loginLayer()
    }

    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Failed to sign up...")
    }

    // MARK - IBActions

    func logOutButtonTapAction(sender: AnyObject) {
        PFUser.logOut()
        self.layerClient.deauthenticateWithCompletion { success, error in
            if (!success) {
                print("Failed to deauthenticate: \(error)")
            } else {
                print("Previous user deauthenticated")
            }
        }
        
        self.presentViewController(self.logInViewController, animated: true, completion: nil)
    }

    // MARK - Layer Authentication Methods

    func loginLayer() {
        SVProgressHUD.show()
		
		let installation = PFInstallation.currentInstallation()
		installation["user"] = PFUser.currentUser()
		installation.saveInBackgroundWithBlock { (success, error) -> Void in
			if error == nil {
				print("saved user")
			}
		}

		
        // Connect to Layer
        // See "Quick Start - Connect" for more details
        // https://developer.layer.com/docs/quick-start/ios#connect
        self.layerClient.connectWithCompletion { success, error in
            if (!success) {
                print("Failed to connect to Layer: \(error)")
            } else {
                let userID: String = PFUser.currentUser()!.objectId!
                // Once connected, authenticate user.
                // Check Authenticate step for authenticateLayerWithUserID source
				print(userID)
                self.authenticateLayerWithUserID(userID, completion: { success, error in
                    if (!success) {
                        print("Failed Authenticating Layer Client with error:\(error)")
                    } else {
                        print("Authenticated")
                        self.presentConversationListViewController()
                    }
                })
            }
        }
    }

    func authenticateLayerWithUserID(userID: NSString, completion: ((success: Bool , error: NSError!) -> Void)!) {
//		print(self.layerClient.authenticatedUserID)

        // Check to see if the layerClient is already authenticated.
        if self.layerClient.authenticatedUserID != nil {
            // If the layerClient is authenticated with the requested userID, complete the authentication process.
            if self.layerClient.authenticatedUserID == userID {
                print("Layer Authenticated as User \(self.layerClient.authenticatedUserID)")
                if completion != nil {
                    completion(success: true, error: nil)
                }
                return
			} else {
                //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
                self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError!) in
                    if error != nil {
                        self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
                            if (completion != nil) {
                                completion(success: success, error: error)
                            }
                        })
                    } else {
                        if completion != nil {
                            completion(success: true, error: error)
                        }
                    }
                }
            }
        } else {
            // If the layerClient isn't already authenticated, then authenticate.
            self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError!) in
                if completion != nil {
                    completion(success: success, error: error)
                }
            })
        }
    }
    
    func authenticationTokenWithUserId(userID: NSString, completion:((success: Bool, error: NSError!) -> Void)!) {
        /*
        * 1. Request an authentication Nonce from Layer
        */
        self.layerClient.requestAuthenticationNonceWithCompletion { (nonce: String!, error: NSError!) in
            if (nonce.isEmpty) {

                if (completion != nil) {
                    completion(success: false, error: error)
                }
                return
			}
			
            /*
            * 2. Acquire identity Token from Layer Identity Service
            */
			

            PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userID]) { (object:AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    let identityToken = object as! String
                    self.layerClient.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
                        if (!authenticatedUserID.isEmpty) {
                            if (completion != nil) {
                                completion(success: true, error: nil)
                            }
                            print("Layer Authenticated as User: \(authenticatedUserID)")
                        } else {
                            completion(success: false, error: error)
                        }
                    }
                } else {
                  print("Parse Cloud function failed to be called to generate token with error: \(error)")
                }
            }
        }
    }

    // MARK - Present ATLPConversationListController

    func presentConversationListViewController() {
        SVProgressHUD.dismiss()
		
		if isSignUp == true {
			let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("ProfileDetailVC") as! ProfileDetailVC
			controller.layerClient = self.layerClient
			let nav: UINavigationController = UINavigationController()
			nav.addChildViewController(controller)
			
			//		self.navigationController?.pushViewController(nav, animated: true)
			self.presentViewController(nav, animated: true, completion: nil)
		}
		
		else {
			let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			
			let controller = storyboard.instantiateViewControllerWithIdentifier("GroupVC") as! GroupVC
			controller.layerClient = self.layerClient
			let nav: UINavigationController = UINavigationController()
			nav.addChildViewController(controller)
			
			self.presentViewController(nav, animated: true, completion: nil)
			

			
		}
        

	}
    
    // MARK - Helper function
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


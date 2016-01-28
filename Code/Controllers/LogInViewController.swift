//
//  LogInViewController.swift
//  UniversiTeam
//
//  Created by Jin Seok Park on 4/16/15.
//  Copyright (c) 2015 Jin Seok Park. All rights reserved.
//

import UIKit

var userId = ""
var userFirstName = ""
var userName = ""
var userFullName = ""

class LogInViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var signupButton2: UIButton!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var loginBtn2: UIButton!
    @IBOutlet var passwordReTextField: UITextField!
    @IBOutlet var notLabel: UILabel!
    @IBOutlet var alreadyLabel: UILabel!
	
	var layerClient: LYRClient!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		

        self.passwordReTextField.hidden = true
        self.signupButton2.hidden = true
        self.loginBtn2.hidden = true
        self.alreadyLabel.hidden = true
		
		
		


        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {

		if (PFUser.currentUser() != nil) {
			self.loginLayer()
			return
		}
		
        self.passwordReTextField.hidden = true
        self.signupButton2.hidden = true
        self.loginBtn.hidden = false
        self.loginBtn2.hidden = true
        self.notLabel.hidden = false
        self.signupButton.hidden = false
        self.alreadyLabel.hidden = true
    }
    
    
    
//    override func supportedInterfaceOrientations() -> Int {
//        return UIInterfaceOrientation.Portrait.rawValue
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signupBtn2_click(sender: AnyObject) {
        
        let user = PFUser()
        user.username = emailTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: emailTextField.text!)
        
        let objects = query.findObjects()
        
        user.signUpInBackgroundWithBlock
            { (succeeded:Bool, signUpError:NSError?) -> Void in
                
                if (self.passwordTextField.text != self.passwordReTextField.text) {
                    let alert = UIAlertView(title: "Error", message: "Password does not match", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                
                if objects != nil {
                    let alert = UIAlertView(title: "Error", message: "You already created an account", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                    
                    
                    if signUpError == nil {
                        let alert = UIAlertView(title: "Congratulations!", message: "Sign Up Successful", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                        
                        //installation
                        let installation:PFInstallation = PFInstallation.currentInstallation()
                        installation["user"] = PFUser.currentUser()
                        installation.saveInBackgroundWithBlock{ (succeeded:Bool, error:NSError?) -> Void in
                            
                            if succeeded == true {
                                print("success")
                            } else {
                                print("There is a certain \(error!.description)")
                            }
                            
                        }
                        
                        
						
                    }
                
        }
        
    }
    
    @IBAction func signupBtn_click(sender: AnyObject) {
        
        self.passwordReTextField.hidden = false
        self.signupButton2.hidden = false
        self.loginBtn.hidden = true
        self.signupButton.hidden = true
        self.notLabel.hidden = true
        self.loginBtn2.hidden = false
        self.alreadyLabel.hidden = false

        
    }
    
    @IBAction func loginBtn2_click(sender: AnyObject) {
        
        self.passwordReTextField.hidden = true
        self.signupButton2.hidden = true
        self.loginBtn.hidden = false
        self.signupButton.hidden = false
        self.notLabel.hidden = false
        self.loginBtn2.hidden = true
        self.alreadyLabel.hidden = true

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }

    @IBAction func loginBtn_click(sender: AnyObject) {
        
        

        
        PFUser.logInWithUsernameInBackground(emailTextField.text!, password: passwordTextField.text!, block: {
            (user:PFUser?, logInError:NSError?)->Void in
            
            if logInError == nil{
                print("Login successful")
                

				userName = PFUser.currentUser()!.username!

				
                //Push Notification Step 2
                let installation:PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackgroundWithBlock{ (succeeded:Bool, error:NSError?) -> Void in
                    
                }
				
				
                
                let currentUser = PFUser.currentUser()

                if let user = currentUser {
					
					let firstName = user["firstName"] as? String
					let lastName = user["lastName"] as? String
					userFullName = "\(firstName!) \(lastName!)"
					
					userId = user.objectId!
					
					
                    
                    if user["Type"] as! String == "Coach" {
                        
                        self.performSegueWithIdentifier("showMainVC", sender: self)

                    }
                    if user["Type"] as! String == "Player" {
                        
                        self.performSegueWithIdentifier("showMainVC", sender: self)
                        
                    }
                    if user["Type"] == nil {
                        
                        self.performSegueWithIdentifier("showMainVC", sender: self)
                    }

                    
                }

                
                
            } else{
                let alert = UIAlertView(title: "Error", message: "Login failed", delegate: self, cancelButtonTitle: "OK")
                alert.show()

                print(logInError)
            }
            
        })
        

    }
	
	func loginLayer() {
		

		SVProgressHUD.show()

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

	
	
	
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
		
        textField.resignFirstResponder()
		
		if self.passwordReTextField.hidden == true {
			loginBtn_click(self)
		} else {
			signupBtn2_click(self)
		}
		
        return true
    }

	func presentConversationListViewController() {

		SVProgressHUD.dismiss()
		
		let tabBarController: UITabBarController = UITabBarController()
		let controller: ConversationListViewController = ConversationListViewController(layerClient: self.layerClient)

		tabBarController.addChildViewController(controller)

		self.navigationController!.pushViewController(tabBarController, animated: true)
	}

	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}





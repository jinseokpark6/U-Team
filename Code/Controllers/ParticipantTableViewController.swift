import UIKit

var isModal = true

class ParticipantTableViewController: ATLParticipantTableViewController {

    // MARK - Lifecycle Methods
	
	var cancelItem: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		

    }
	
	override func viewDidAppear(animated: Bool) {
		
		println("HI?")
		if isModal {
			self.navigationItem.hidesBackButton = true
			let title = NSLocalizedString("Done",  comment: "")
			cancelItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleCancelTap"))
			cancelItem.tintColor = UIColor.whiteColor()
			self.navigationItem.rightBarButtonItem = cancelItem
			
			self.allowsMultipleSelection = true
		} else {
			self.title = "Members"
			self.navigationItem.hidesBackButton = false
		}

	}

    // MARK - Actions

    func handleCancelTap() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
		
//		self.navigationController?.popToRootViewControllerAnimated(true)
    }
	
	public override func supportedInterfaceOrientations() -> Int {
		return UIInterfaceOrientation.Portrait.rawValue
	}
	
	public override func shouldAutorotate() -> Bool {
		return false
	}

}

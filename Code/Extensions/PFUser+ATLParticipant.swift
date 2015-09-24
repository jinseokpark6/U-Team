import Foundation

extension PFUser: ATLParticipant {

    public var firstName: String {
        return self.objectForKey("firstName") as! String
    }

    public var lastName: String {
        return self.objectForKey("lastName") as! String
    }

    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    public var participantIdentifier: String {
        return self.objectId!
    }

    public var avatarImageURL: NSURL? {
        return nil
    }

    public var avatarImage: UIImage? {
//		var photo: UIImage? = UIImage?()
		if let file = self.objectForKey("photo") as? PFFile {
			let data = file.getData()
			let photo = UIImage(data: data!)
//			file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
//				if error == nil {
//					photo = UIImage(data: data!)
//				}
//			})
			return photo
		} else {
			return nil
		}
    }

    public var avatarInitials: String {
        let initials = "\(getFirstCharacter(self.firstName))\(getFirstCharacter(self.lastName))"
        return initials.uppercaseString
    }
    
    private func getFirstCharacter(value: String) -> String {
        return (value as NSString).substringToIndex(1)
    }
}
import Foundation

class UserManager {
    static let sharedManager = UserManager()
    var userCache: NSCache = NSCache()

    // MARK Query Methods
    func queryForUserWithName(searchText: String, completion: ((NSArray?, NSError?) -> Void)) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            var contacts = [PFUser]()
            if (error == nil) {
                for user: PFUser in (objects as! [PFUser]) {
                    if user.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
                        contacts.append(user)
                    }
				}
				println(contacts)
            }
            completion(contacts, error)
        }
    }

	func queryTeamForUserWithName(searchText: String, teamId: String, completion: ((NSArray?, NSError?) -> Void)) {
		let teamQuery: PFQuery! = PFQuery(className:"Team")
		teamQuery.whereKey("objectId", equalTo: teamId)
		let pfObject = teamQuery.getFirstObject()
		var teamPlayerIDs = pfObject?.valueForKey("players") as! [String]
		var teamCoachIDs = pfObject?.valueForKey("coach") as! [String]
		
		for var i=0; i<teamCoachIDs.count; i++ {
			teamPlayerIDs.append(teamCoachIDs[i])
		}
		
		
		
		let query: PFQuery! = PFUser.query()
		query.whereKey("objectId", containedIn: teamPlayerIDs)
		
		query.findObjectsInBackgroundWithBlock { objects, error in
			var contacts = [PFUser]()
			if (error == nil) {
				for user: PFUser in (objects as! [PFUser]) {
					if user.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
						contacts.append(user)
					}
				}
				println(contacts)
			}
			completion(contacts, error)
		}
	}

	
	
    func queryForAllUsersWithCompletion(completion: ((NSArray?, NSError?) -> Void)?) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
		query.addAscendingOrder("firstName")
        query.findObjectsInBackgroundWithBlock { objects, error in
            if let callback = completion {
				println("HIYA")
                callback(objects, error)
            }
        }
    }
	
	func queryForTeamUsersWithCompletion(teamId: String, includeCurrUser: Bool, completion: ((NSArray?, NSError?) -> Void)?) {
		let teamQuery: PFQuery! = PFQuery(className:"Team")
		teamQuery.whereKey("objectId", equalTo: teamId)
		let pfObject = teamQuery.getFirstObject()
		
		var teamIDs = [String]()
		
		if let teamPlayerIDs = pfObject?.valueForKey("players") as? [String] {
			teamIDs = teamPlayerIDs
		}
		if let teamCoachIDs = pfObject?.valueForKey("coach") as? [String] {
			for var i=0; i<teamCoachIDs.count; i++ {
				teamIDs.append(teamCoachIDs[i])
			}
		}

		
		println(teamIDs)
		
		let query: PFQuery! = PFUser.query()
		query.whereKey("objectId", containedIn: teamIDs)
		
		if !includeCurrUser {
			query.whereKey("objectId", notEqualTo: (PFUser.currentUser()?.objectId)!)
		}
		
		query.addAscendingOrder("firstName")
		query.findObjectsInBackgroundWithBlock { objects, error in
			if let callback = completion {
				println("HIYA")
				println(objects)
				callback(objects, error)
			}
		}
	}
	
	func queryForTeamCoachWithCompletion(teamId: String, includeCurrUser: Bool, completion: ((NSArray?, NSError?) -> Void)?) {
		let teamQuery: PFQuery! = PFQuery(className:"Team")
		teamQuery.whereKey("objectId", equalTo: teamId)
		let pfObject = teamQuery.getFirstObject()
		
		var teamIDs = [String]()
		
		if let teamCoachIDs = pfObject?.valueForKey("coach") as? [String] {
			teamIDs = teamCoachIDs
		}
		
		
		println(teamIDs)
		
		let query: PFQuery! = PFUser.query()
		query.whereKey("objectId", containedIn: teamIDs)
		
		if !includeCurrUser {
			query.whereKey("objectId", notEqualTo: (PFUser.currentUser()?.objectId)!)
		}
		
		query.addAscendingOrder("firstName")
		query.findObjectsInBackgroundWithBlock { objects, error in
			if let callback = completion {
				callback(objects, error)
			}
		}
	}
	
	func queryForTeamPlayersWithCompletion(teamId: String, includeCurrUser: Bool, completion: ((NSArray?, NSError?) -> Void)?) {
		let teamQuery: PFQuery! = PFQuery(className:"Team")
		teamQuery.whereKey("objectId", equalTo: teamId)
		let pfObject = teamQuery.getFirstObject()
		
		var teamIDs = [String]()
		
		if let teamPlayerIDs = pfObject?.valueForKey("players") as? [String] {
			teamIDs = teamPlayerIDs
		}
		
		
		println(teamIDs)
		
		let query: PFQuery! = PFUser.query()
		query.whereKey("objectId", containedIn: teamIDs)
		
		if !includeCurrUser {
			query.whereKey("objectId", notEqualTo: (PFUser.currentUser()?.objectId)!)
		}
		
		query.addAscendingOrder("firstName")
		query.findObjectsInBackgroundWithBlock { objects, error in
			if let callback = completion {
				callback(objects, error)
			}
		}
	}



    func queryAndCacheUsersWithIDs(userIDs: [String], completion: ((NSArray?, NSError?) -> Void)?) {
        let query: PFQuery! = PFUser.query()
        query.whereKey("objectId", containedIn: userIDs)
        query.findObjectsInBackgroundWithBlock { objects, error in
            if (error == nil) {
                for user: PFUser in (objects as! [PFUser]) {
                    self.cacheUserIfNeeded(user)
					
					println(user)

                }
            }
            if let callback = completion {
                callback(objects, error)
            }
        }
    }

    func cachedUserForUserID(userID: NSString) -> PFUser? {
        if self.userCache.objectForKey(userID) != nil {
            return self.userCache.objectForKey(userID) as! PFUser?
        }
        return nil
    }

    func cacheUserIfNeeded(user: PFUser) {
        if self.userCache.objectForKey(user.objectId!) == nil {
            self.userCache.setObject(user, forKey: user.objectId!)
        }
    }

    func unCachedUserIDsFromParticipants(participants: NSArray) -> NSArray {
        var array = [String]()
        for userID: String in (participants as! [String]) {
            if (userID == PFUser.currentUser()!.objectId!) {
                continue
            }
            if self.userCache.objectForKey(userID) == nil {
                array.append(userID)
            }
        }
        
        return NSArray(array: array)
    }

    func resolvedNamesFromParticipants(participants: NSArray) -> NSArray {
        var array = [String]()
        for userID: String in (participants as! [String]) {
            if (userID == PFUser.currentUser()!.objectId!) {
                continue
            }
            if self.userCache.objectForKey(userID) != nil {
                let user: PFUser = self.userCache.objectForKey(userID) as! PFUser
                array.append(user.firstName)
            }
        }
        return NSArray(array: array)
    }
    
}
//
//  GitHubUserListViewModel.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import Foundation
import CoreData

enum PullUpState {
  case PullHint
  case Release
  case ReachLimit
}

class GitHubUserListViewModel: NSObject {
  let pullUpRevealHeight: CGFloat = 80.0
  let dataLimit: Int = 100
  var userListFRC: NSFetchedResultsController<GitUser>!
  fileprivate var sinceUserID: Int64 = 0
}

extension GitHubUserListViewModel {
  func updateSinceUserIDFromFRC() {
    if (userListFRC.fetchedObjects?.count ?? 0) > 0,
       let lastObject = userListFRC.fetchedObjects?.last {
      sinceUserID = lastObject.userID
    } else {
      sinceUserID = 0
    }
  }
  
  func setFRC() {
    userListFRC = GitUserHandler.getUserListFRC()
  }
  
  func getFRCDataCount() -> Int {
    return userListFRC.fetchedObjects?.count ?? 0
  }
  
  func getFRCUserObject(at index: Int) -> GitUser? {
    guard index < getFRCDataCount() else { return nil }
    return userListFRC.fetchedObjects?[index] as? GitUser
  }
}

// MARK: DB
extension GitHubUserListViewModel {
  func deleteAllUser() {
    GitUserHandler.deleteAllData()
  }
}

// MARK: Network
extension GitHubUserListViewModel {
  func getUserList(_ sinceNumber: Int64? = nil) {
    var since = sinceUserID
    
    if let sinceNum = sinceNumber {
      since = sinceNum
    }
    
    NetworkController.shared.getUserList(since: since)
  }
}

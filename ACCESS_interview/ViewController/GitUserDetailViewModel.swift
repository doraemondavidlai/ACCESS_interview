//
//  GitUserDetailViewModel.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/15.
//

import Foundation
import CoreData

class GitUserDetailViewModel: NSObject {
  var userFRC: NSFetchedResultsController<GitUser>!
  fileprivate var userID: Int64!
}

extension GitUserDetailViewModel {
  func checkIsNeedToFetchDetail() {
    if (userFRC.fetchedObjects?.count ?? 0) > 0,
       let user = userFRC.fetchedObjects?[0],
       user.name == nil,
       let loginName = user.login {
      getUserDetail(loginName: loginName)
    }
  }
  
  func getUserObject() -> GitUser? {
    guard (userFRC.fetchedObjects?.count ?? 0) > 0,
          let userObject = userFRC.fetchedObjects?[0] else {
      return nil
    }
    return userObject
  }
  
  func getBlogURL() -> URL? {
    guard let userObject = getUserObject(),
          let blogUrlString = userObject.blog,
          let url = URL(string: blogUrlString) else {
      return nil
    }
    return url
  }
}

// MARK: DB
extension GitUserDetailViewModel {
  func setFRC(id: Int64) {
    userID = id
    userFRC = GitUserHandler.getUserFRC(userID: userID)
  }
  
  func updateUserName(_ newName: String) {
    guard let userObject = getUserObject(),
          newName != userObject.name else {
      return
    }
    
    GitUserHandler.updateUserName(id: userObject.userID, name: newName)
  }
}

// MARK: Network
extension GitUserDetailViewModel {
  fileprivate func getUserDetail(loginName: String) {
    NetworkController.shared.getUserDetail(loginName: loginName)
  }
}

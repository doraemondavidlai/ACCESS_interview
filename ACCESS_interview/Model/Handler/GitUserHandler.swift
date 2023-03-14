//
//  GitUserHandler.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit
import CoreData

extension GitUser: NSManagedObjectType {
  @objc static var entityName: String { return "GitUser" }
}

class GitUserHandler: NSObject {
  class func getUserListFRC() -> NSFetchedResultsController<GitUser> {
    let context = CoreDataHandler.shared.viewContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(GitUser.userID), ascending: true)]
    
    let frc: NSFetchedResultsController<GitUser> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    
    do {
      try frc.performFetch()
    } catch {
      let fetchError = error as NSError
      assertionFailure("\(fetchError), \(fetchError.userInfo)")
    }
    
    return frc
  }
  
  class func getUserFRC(userID: Int64) -> NSFetchedResultsController<GitUser> {
    let context = CoreDataHandler.shared.viewContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    request.predicate = NSPredicate(format: "%K == %d", #keyPath(GitUser.userID), userID)
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(GitUser.userID), ascending: true)]
    
    let frc: NSFetchedResultsController<GitUser> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    
    do {
      try frc.performFetch()
    } catch {
      let fetchError = error as NSError
      assertionFailure("\(fetchError), \(fetchError.userInfo)")
    }
    
    return frc
  }
  
  class func updateUsers(_ users: [NSMutableDictionary]) {
    let context = CoreDataHandler.shared.viewContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    
    guard let results = try? context.fetch(request) else { return }
    
    context.performAndWait {
      for userObject in users {
        guard let id = userObject.object(forKey: "id") as? Int else {
          continue
        }
        
        if let index = results.firstIndex(where: { gitUser in
          gitUser.userID == id
        }) {
          // update
          let record: GitUser = results[index]
          record.userID = Int64(id)
          record.login = userObject.object(forKey: "login") as? String ?? ""
          record.avatarUrl = userObject.object(forKey: "avatar_url") as? String ?? ""
          record.isSiteAdmin = NSNumber(booleanLiteral: userObject.object(forKey: "site_admin") as? Bool ?? false).int32Value
          
        } else {
          // add
          let record: GitUser = context.insertObject()
          record.userID = Int64(id)
          record.login = userObject.object(forKey: "login") as? String ?? ""
          record.avatarUrl = userObject.object(forKey: "avatar_url") as? String ?? ""
          record.isSiteAdmin = NSNumber(booleanLiteral: userObject.object(forKey: "site_admin") as? Bool ?? false).int32Value
          record.name = nil
          record.bio = nil
          record.location = nil
          record.blog = nil
        }
      }
      
      context.saveContext()
    }
  }
  
  class func updateUserDetail(id: Int, name: String, bio: String, location: String, blog: String) {
    let context = CoreDataHandler.shared.viewContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    request.predicate = NSPredicate(format: "%K == %d", #keyPath(GitUser.userID), id)
    
    guard let results = try? context.fetch(request) else { return }
    
    // update
    guard let record = results.first else {
      return
    }
    
    context.performAndWait {
      record.name = name
      record.bio = bio
      record.location = location
      record.blog = blog
      context.saveContext()
    }
  }
  
  class func deleteAllData() {
    let context = CoreDataHandler.shared.viewContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    
    guard let results = try? context.fetch(request) else { return }
    
    if results.isEmpty { return }
    
    context.performAndWait {
      for record in results {
        context.delete(record)
      }
      
      context.saveContext()
    }
  }
}

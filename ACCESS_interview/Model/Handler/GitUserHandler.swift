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
  class func getUserFRC() -> NSFetchedResultsController<GitUser> {
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
  
  class func updateUser(id: Int, login: String, avatarUrl: String, isSiteAdmin: Int) {
    let context = CoreDataHandler.shared.backgroundContext
    let request: NSFetchRequest<GitUser> = GitUser.fetchRequest()
    request.predicate = NSPredicate(format: "%K == %d", #keyPath(GitUser.userID), id)
    
    guard let results = try? context.fetch(request) else { return }
    
    if !results.isEmpty {
      // update
      guard let record = results.first else {
        return
      }
      
      context.performAndWait {
        record.userID = Int64(id)
        record.login = login
        record.avatarUrl = avatarUrl
        record.isSiteAdmin = Int32(isSiteAdmin)
        context.saveContext()
      }
    } else {
      // add
      context.performAndWait {
        let record: GitUser = context.insertObject()
        record.userID = Int64(id)
        record.login = login
        record.avatarUrl = avatarUrl
        record.isSiteAdmin = Int32(isSiteAdmin)
        record.name = nil
        record.bio = nil
        record.location = nil
        record.blog = nil
        context.saveContext()
      }
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

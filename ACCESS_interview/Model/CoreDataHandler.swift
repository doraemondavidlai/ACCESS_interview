//
//  CoreDataHandler.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit
import CoreData

class CoreDataHandler: NSObject {
  static let shared = CoreDataHandler()
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "ACCESS_interview")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  lazy var viewContext: NSManagedObjectContext = {
    return persistentContainer.viewContext
  }()
  
  lazy var backgroundContext: NSManagedObjectContext = {
    return persistentContainer.newBackgroundContext()
  }()
}

protocol NSManagedObjectType {
  static var entityName: String { get }
}

//MARK: - NSManagedObjectContext extension
extension NSManagedObjectContext {
  func insertObject<T: NSManagedObject>() -> T where T: NSManagedObjectType {
    guard let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else {
      fatalError("Entity \(T.entityName) does not correspond to \(T.self)")
    }
    
    return obj
  }
  
  func saveContext() {
    performAndWait {
      if self.hasChanges {
        do {
          try self.save()
        } catch {
          let nserror = error as NSError
          print("Failed to save to data store \(nserror.localizedDescription)")
          let detailErrors = nserror.userInfo[NSDetailedErrorsKey] as? NSArray
          
          if let tempErrors = detailErrors, tempErrors.count > 0 {
            for error in tempErrors {
              let tempError = error as! NSError
              print("save to data failed \(tempError.userInfo)")
            }
          }
          
#if SWIFT_DEBUG
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
#endif
        }
      }
    }
  }
}

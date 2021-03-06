//
//  PersistenceService.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/06/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PersistenceService: NSObject {
    
    static let shared = PersistenceService()
    private override init() {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Telabook")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
//        container.viewContext.concurrencyType = NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}



extension PersistenceService {
    func fetchUserFromStorage() -> UserObject? {
        let managedObjectContext = PersistenceService.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserObject>(entityName: "User")
        let sortDescriptor1 = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            let user = try managedObjectContext.fetch(fetchRequest)
            return user.first
        } catch let error {
            print(error)
            return nil
        }
    }
    func applicationDocumentsDirectory() {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yo.BlogReaderApp" in the application's documents directory.
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}

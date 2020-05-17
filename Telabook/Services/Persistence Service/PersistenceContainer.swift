//
//  PersistenceContainer.swift
//  Telabook
//
//  Created by Anmol Rajpal on 01/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer {
//    private static let lastCleanedKey = "lastCleaned"

    static let shared: PersistentContainer = {
//        ValueTransformer.setValueTransformer(ColorTransformer(), forName: NSValueTransformerName(rawValue: String(describing: ColorTransformer.self)))
        
        let container = PersistentContainer(name: "Telabook")
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            
            print("Successfully loaded persistent store at: \(desc.url?.description ?? "nil")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
//    var lastCleaned: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: PersistentContainer.lastCleanedKey) as? Date
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: PersistentContainer.lastCleanedKey)
//        }
//    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = super.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
//        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        backgroundContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        return backgroundContext
    }
}

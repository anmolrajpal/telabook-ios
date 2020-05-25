//
//  UserMessage.swift
//  Telabook
//
//  Created by Anmol Rajpal on 25/05/20.
//  Copyright © 2020 Natovi. All rights reserved.
//

import Foundation
import CoreData
import MessageKit

extension UserMessage {
    convenience init(context: NSManagedObjectContext, messageEntryFromFirebase entry:FirebaseMessage) {
        self.init(context: context)
        
    }
}

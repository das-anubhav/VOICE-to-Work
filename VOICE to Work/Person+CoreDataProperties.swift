//
//  Person+CoreDataProperties.swift
//  VOICE to Work
//
//  Created by ANUBHAV DAS on 16/08/20.
//  Copyright © 2020 Captain Anubhav. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var title: String?
    @NSManaged public var note: String?

}

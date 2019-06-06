//
//  Event.swift
//  ReligiousApp
//
//  Created by Trenton Parrotte on 5/22/19.
//  Copyright © 2019 Trenton Parrotte. All rights reserved.
//

import Foundation
import UIKit
import os.log

//Class representing Event object that we can pass around throughout the app
class Event: NSObject, NSCoding{
    
    //MARK: Properties
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var tradition: String
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("events")
    
    //MARK: Type
    struct PropertyKey {
        static let name = "name"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let tradition = "tradition"
    }
    
    public override init(){
        name = ""
        startDate = Date.distantPast
        endDate = Date.distantPast
        tradition = ""
    }
    
    public init(title: String, start: Date, end: Date, tradition: String){
        name = title
        startDate = start
        endDate = end
        self.tradition = tradition
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(startDate, forKey: PropertyKey.startDate)
        aCoder.encode(endDate, forKey: PropertyKey.endDate)
        aCoder.encode(tradition, forKey: PropertyKey.tradition)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //All instances are mandatory
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for an Event object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let startDate = aDecoder.decodeObject(forKey: PropertyKey.startDate) as? Date else {
            os_log("Unable to decode the startDate for an Event object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let endDate = aDecoder.decodeObject(forKey: PropertyKey.endDate) as? Date else {
            os_log("Unable to decode the endDate for an Event object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tradition = aDecoder.decodeObject(forKey: PropertyKey.tradition) as? String else {
            os_log("Unable to decode the name for a Event object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(title: name, start: startDate, end: endDate, tradition: tradition)
        
    }
    
    
}


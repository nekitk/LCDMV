//
//  Timer.swift
//  LCDMV
//
//  Created by neekitkah on 30.07.14.
//  Copyright (c) 2014 nekitk. All rights reserved.
//

import Foundation
import CoreData

@objc(Timer)

class Timer: NSManagedObject {

    @NSManaged var completed: Bool
    @NSManaged var endMoment: NSDate
    @NSManaged var isContinuous: Bool
    @NSManaged var name: String
    @NSManaged var seconds: NSDecimalNumber
    @NSManaged var startMoment: NSDate

}

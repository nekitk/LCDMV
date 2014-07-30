import UIKit
import CoreData

//Без этого не получится кастовать зафетченные объекты в таймеры
@objc(Timer)

class Timer: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var seconds: NSNumber
    @NSManaged var isContinuous: Bool
    @NSManaged var completed: Bool
    @NSManaged var startMoment: NSDate!
    @NSManaged var endMoment: NSDate!
    
}
import UIKit
import CoreData

//Без этого не получится кастовать зафетченные объекты в таймеры
@objc(Timer)

class Timer: NSManagedObject, Printable {
    @NSManaged var name: String
    @NSManaged var seconds: NSNumber
    @NSManaged var isContinuous: Bool
    @NSManaged var completed: Bool
    @NSManaged var startMoment: NSDate!
    @NSManaged var endMoment: NSDate!
    
    override var description: String {
        return "\(name)"
    }
    
    func isToDo() -> Bool {
        if seconds == 0 && !isContinuous {
            return true
        }
        else {
            return false
        }
    }
    
    
}
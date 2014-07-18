import UIKit

class Timer: NSObject {
    var name: String
    var seconds: Int
    var isContinuous: Bool
    var completed: Bool
    var startMoment: NSDate!
    var endMoment: NSDate!
    
    init(name: String, seconds: Int, isContinuous: Bool, completed: Bool, startMoment: NSDate!, endMoment: NSDate!) {
        self.name = name
        self.seconds = seconds
        self.isContinuous = isContinuous
        self.completed = completed
        self.startMoment = startMoment
        self.endMoment = endMoment
        
        super.init()
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
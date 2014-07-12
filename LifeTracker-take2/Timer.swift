import UIKit

class Timer: NSObject {
    var name: String
    var seconds: Int
    var isContinuous: Bool
    var completed: Bool
    
    init(name: String, seconds: Int, isContinuous: Bool, completed: Bool) {
        self.name = name
        self.seconds = seconds
        self.isContinuous = isContinuous
        self.completed = completed
    }
}
import UIKit

let timersManager: TimersManager = TimersManager()

struct timer {
    var name: String
    var minutes: Int
    var seconds: Int
}

class TimersManager: NSObject {
    var timers = timer[]()
    var currentTimer: Int?
    
    init() {
        super.init()
        
        addTimer("Test", minutes: 0, seconds: 4)
    }
    
    func addTimer(name: String, minutes: Int, seconds: Int) {
        timers.append(timer(name: name, minutes: minutes, seconds: seconds))
    }
    
    func setCurrent(index: Int) {
        currentTimer = index
    }
    
    func getCurrent() -> timer! {
        if currentTimer {
            return timers[currentTimer!]
        }
        else {
            return nil
        }
    }
}

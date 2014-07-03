import UIKit

let timersManager = TimersManager()

struct timer {
    var name: String
    var seconds: Int
    var isContinuos: Bool
}

class TimersManager: NSObject {
    var timers = Dictionary<Int, timer>()
    
    var currentTimer: Int?
    
    init() {
        super.init()
        
        addTimer("Test", minutes: 0, seconds: 4)
        addTimer("Quarter", minutes: 0, seconds: 15)
    }
    
    func addTimer(name: String, minutes: Int, var seconds: Int, isContinuos: Bool = false) {
        seconds += minutes * 60
        
        //todo proper ID generator (just ++ it every addTimer call)
        let newTimerId = timers.count
        
        timers[newTimerId] = timer(name: name, seconds: seconds, isContinuos: isContinuos)
    }
    
    func setCurrent(index: Int) {
        currentTimer = index
    }
    
    func getCurrent() -> (timer!, Int!) {
        if currentTimer {
            return (timers[currentTimer!], currentTimer!)
        }
        else {
            return (nil, nil)
        }
    }
    
    func removeTimer(index: Int) {
        pomodoroManager.removePomodorosOfTimer(index)
        timers[index] = nil
    }
    
}

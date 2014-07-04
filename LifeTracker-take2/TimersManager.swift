import UIKit

let timersManager = TimersManager()

class TimersManager: NSObject {
    
    var timers = Timer[]()
    
    var currentTimerIndex: Int?
    
    init() {
        super.init()
        
        addTimer("Test", minutes: 0, seconds: 4)
        addTimer("Quarter", minutes: 0, seconds: 15)
    }
    
    func addTimer(name: String, minutes: Int, var seconds: Int, isContinuos: Bool = false) {
        seconds += minutes * 60
        
        //todo get rid of this shit
        let newTimerId = timers.count
        
        timers.append(Timer(name: name, seconds: seconds, isContinuos: isContinuos))
    }
    
    func setCurrent(index: Int) {
        currentTimerIndex = index
    }
    
    func getCurrent() -> Timer? {
        if currentTimerIndex {
            return timers[currentTimerIndex!]
        }
        else {
            return nil
        }
    }
    
    func removeTimer(timerToRemoveIndex: Int) {
        if timerToRemoveIndex == currentTimerIndex {
            println("Cannot remove current timer")
            return
        }
        
        pomodoroManager.removePomodorosOfTimer(timers[timerToRemoveIndex])
        timers.removeAtIndex(timerToRemoveIndex)
    }
    
//    func getTimerIndex(timer timerToFind: Timer) -> Int? {
//        for (timerIndex, timer) in enumerate(timers) {
//            if timerToFind == timer {
//                return timerIndex
//            }
//        }
//        
//        return nil
//    }
    
}

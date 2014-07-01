import UIKit

let pomodoroManager = PomodoroManager()

struct pomodoro {
    var timerIndex: Int
    var dateStarted: NSDate
    var durationInSec: Int
}

class PomodoroManager: NSObject {
   
    var pomodoros = pomodoro[]()
    
    init() {
        super.init()
        
//        self.trackTimer(0)
    }
    
    func trackTimer(timerIndex: Int) {
        let timer = timersManager.timers[timerIndex]
        let duration = timer.minutes * 60 + timer.seconds
        pomodoros += pomodoro(timerIndex: timerIndex, dateStarted: NSDate(), durationInSec: duration)
    }
    
}

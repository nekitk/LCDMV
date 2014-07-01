import UIKit

let pomodoroManager = PomodoroManager()

struct pomodoro {
    var timerIndex: Int
    var dateStarted: NSDate
    var durationInSec: Int
}

class PomodoroManager: NSObject {
   
    var pomodoros = pomodoro[]()
    
    func trackTimer(timerIndex: Int) {
        let timer = timersManager.timers[timerIndex]
        let duration = timer.minutes * 60 + timer.seconds
        
        //todo current date is end date, not the start date
        let dateStarted = NSDate()
        
        pomodoros += pomodoro(timerIndex: timerIndex, dateStarted: dateStarted, durationInSec: duration)
    }
    
}

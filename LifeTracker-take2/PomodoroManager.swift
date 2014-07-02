import UIKit

let pomodoroManager = PomodoroManager()

struct pomodoro {
    var timerIndex: Int
    var dateStarted: NSDate
    var durationInSec: Int
}

class PomodoroManager: NSObject {
   
    var pomodoros = pomodoro[]()
    
    func trackTimer(timerIndex: Int, launchDate: NSDate, overTimeSeconds: Int) {
        let timer = timersManager.timers[timerIndex]
        let duration = timer.minutes * 60 + timer.seconds + overTimeSeconds
        
        pomodoros += pomodoro(timerIndex: timerIndex, dateStarted: launchDate, durationInSec: duration)
    }
    
}

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
        if let timer = timersManager.timers[timerIndex] {
            let duration = timer.seconds + overTimeSeconds
            
            if duration > 0 {
                pomodoros += pomodoro(timerIndex: timerIndex, dateStarted: launchDate, durationInSec: duration)
            }
        }
    }
    
    func removePomodorosOfTimer(timerIndex: Int) {
        for (pomodoroIndex, pomodoro) in enumerate(pomodoros) {
            if pomodoro.timerIndex == timerIndex {
                pomodoros.removeAtIndex(pomodoroIndex)
                
                // Recursion! Without it there'll be problems with indexes
                //  because after each removal indexes change
                removePomodorosOfTimer(timerIndex)
                return
            }
        }
    }
    
}

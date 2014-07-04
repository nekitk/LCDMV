import UIKit

let pomodoroManager = PomodoroManager()

struct pomodoro {
    var timer: Timer
    var dateStarted: NSDate
    var durationInSec: Int
}

class PomodoroManager: NSObject {
   
    var pomodoros = pomodoro[]()
    
    func trackTimer(timer: Timer, launchDate: NSDate, overTimeSeconds: Int) {

        let duration = timer.seconds + overTimeSeconds
        
        if duration > 0 {
            pomodoros += pomodoro(timer: timer, dateStarted: launchDate, durationInSec: duration)
        }
    }
    
    func removePomodorosOfTimer(timer: Timer) {
        for (pomodoroIndex, pomodoro) in enumerate(pomodoros) {
            if pomodoro.timer == timer {
                pomodoros.removeAtIndex(pomodoroIndex)
                
                // Recursion! Without it there'll be problems with indexes
                //  because after each removal indexes change
                removePomodorosOfTimer(timer)
                return
            }
        }
    }
    
}

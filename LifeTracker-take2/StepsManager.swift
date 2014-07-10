import UIKit

let stepsManager = StepManager()

struct step {
    var timer: Timer
    var dateStarted: NSDate
    var durationInSec: Int
}

class StepManager: NSObject {
   
    var steps = step[]()
    
    func trackTimer(timer: Timer, launchDate: NSDate, duration: Int) {
        if duration > 0 {
            steps += step(timer: timer, dateStarted: launchDate, durationInSec: duration)
        }
    }
    
    func removeStepsOfTimer(timer: Timer) {
        for (stepIndex, step) in enumerate(steps) {
            if step.timer == timer {
                steps.removeAtIndex(stepIndex)
                
                // Recursion! Without it there'll be problems with indexes
                //  because after each removal indexes change
                removeStepsOfTimer(timer)
                return
            }
        }
    }
    
}

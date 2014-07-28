import UIKit
import CoreData

var currentTimer: Timer!

let timersManager = TimersManager()

class TimersManager: NSObject, Printable {
    
    private var timers = [Timer]()
    
    var context: NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    }
    
    var timersCount: Int {
        return timers.count
    }
    
    var currentTimerIndex: Int! {
        if currentTimer {
            return (timers as NSArray).indexOfObject(currentTimer)
        }
        else {
            return nil
        }
    }
    
    override var description: String {
        var stringToPrint = "\n"
        for (index, timer: Timer) in enumerate(timers) {
            stringToPrint += "[\(index)] \(timer)\n"
        }
        return stringToPrint
    }
    
    init() {
        super.init()
        
        let request = NSFetchRequest(entityName: "Timers")
        request.returnsObjectsAsFaults = false
        timers = context.executeFetchRequest(request, error: nil) as [Timer]
    }
    
    func getTimerByIndex(index: Int) -> Timer {
        return timers[index]
    }
    
    func hasNextUncompleted() -> Bool {
        for timer in timers {
            if !timer.completed {
                return true
            }
        }
        
        return false
    }
    
    func moveToNextTimer() {
        for timer in timers {
            if !timer.completed {
                currentTimer = timer
                return
            }
        }
        
        currentTimer = nil
    }
    
    func moveTimer(fromIndex sourceIndex: Int, toIndex newIndex: Int) {
        let movingTimer: Timer = timers.removeAtIndex(sourceIndex)
        timers.insert(movingTimer, atIndex: newIndex)
        
        //todo Сохранять порядок
    }
    
    func addTimer(name: String, minutes: Int, seconds: Int, isContinuous: Bool) {
        let entity = NSEntityDescription.entityForName("Timers", inManagedObjectContext: context)
        
        let newTimer = Timer(entity: entity, insertIntoManagedObjectContext: context)
        newTimer.name = name
        newTimer.seconds = Int64(minutes * 60 + seconds)
        newTimer.isContinuous = isContinuous
        newTimer.completed = false
        
        timers.append(newTimer)
        
        context.save(nil)
    }
    
    func removeTimer(timerToRemoveIndex: Int) {
        let timerToRemove = timers.removeAtIndex(timerToRemoveIndex)
        context.deleteObject(timerToRemove)
        context.save(nil)
    }
    
    
    // Отмечаем как выполненный
    func markTimerAsCompleted(timer: Timer, secondsPassed: Int, startMoment: NSDate) {
        timer.completed = true
        timer.seconds = Int64(secondsPassed)
        timer.startMoment = startMoment
        timer.endMoment = NSDate()
        
        context.save(nil)
    }
    
    
    func getUncompletedTimersCount() -> Int {
        var uncompletedTimersCount = 0
        
        for timer in timers {
            if !timer.completed {
                ++uncompletedTimersCount
            }
        }
        
        return uncompletedTimersCount
    }
    
}
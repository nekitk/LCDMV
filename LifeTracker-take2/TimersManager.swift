import UIKit
import CoreData

var currentTimer: Timer!
var currentTimerIndex: Int!

let timersManager = TimersManager()

class TimersManager: NSObject {
    
    var timers = [Timer]()
    
    init() {
        super.init()
        
        loadTimersFromCoreData()
    }
    
    func getTimerByIndex(index: Int) -> Timer {
        return timers[index]
    }
    
    func getTimersCount() -> Int {
        return timers.count
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
        for (index, timer: Timer) in enumerate(timers) {
            if !timer.completed {
                currentTimer = timer
                currentTimerIndex = index
                return
            }
        }
    }
    
    func loadTimersFromCoreData() {
        //Clean up timers list
        timers = []
        
        let fetchedTimers = retrieveAllTimersFromCoreData().results
        
        //Fetching results
        if !fetchedTimers.isEmpty {
            for fetchedTimer in fetchedTimers {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedSeconds = fetchedTimer.valueForKey("seconds") as Int
                let fetchedIsContinuous = fetchedTimer.valueForKey("isContinuous") as Bool
                let fetchedCompleted = fetchedTimer.valueForKey("completed") as Bool
                
                var fetchedStartMoment: NSDate!
                var fetchedEndMoment: NSDate!
                
                if fetchedCompleted {
                    fetchedStartMoment = fetchedTimer.valueForKey("startMoment") as NSDate
                    fetchedEndMoment = fetchedTimer.valueForKey("endMoment") as NSDate
                }
                
                timers.append(Timer(name: fetchedName, seconds: fetchedSeconds, isContinuous: fetchedIsContinuous, completed: fetchedCompleted, startMoment: fetchedStartMoment, endMoment: fetchedEndMoment))
            }
        }
    }
    
    func addTimer(name: String, minutes: Int, seconds: Int, isContinuous: Bool = false) {
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        var timerToBeSaved = NSEntityDescription.insertNewObjectForEntityForName("Timers", inManagedObjectContext: context) as NSManagedObject
        
        timerToBeSaved.setValue(name, forKey: "name")
        timerToBeSaved.setValue(minutes * 60 + seconds, forKey: "seconds")
        timerToBeSaved.setValue(isContinuous, forKey: "isContinuous")
        timerToBeSaved.setValue(false, forKey: "completed")
        
        context.save(nil)
        
        // Reload timers list
        loadTimersFromCoreData()
    }
    
    func removeTimer(timerToRemoveIndex: Int) {
        let removingTimerName = timers[timerToRemoveIndex].name
        let removingTimerDuration = timers[timerToRemoveIndex].seconds

        let (context, fetchedTimers) = retrieveAllTimersFromCoreData()
        
        //Fetching results
        if !fetchedTimers.isEmpty {
            fetchLoop: for fetchedTimer in fetchedTimers {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedDuration = fetchedTimer.valueForKey("seconds") as Int
                
                //Delete timer with such a name
                if (fetchedName == removingTimerName) && (fetchedDuration == removingTimerDuration)
                {
                    context.deleteObject(fetchedTimer)
                    break fetchLoop
                }
            }
            
            context.save(nil)
            
            loadTimersFromCoreData()
        }
        
    }
    
    func retrieveAllTimersFromCoreData() -> (context: NSManagedObjectContext, results: [NSManagedObject]) {
        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Timers")
        let results = context.executeFetchRequest(request, error: nil) as [NSManagedObject]
        
        return (context, results)
    }
    
    func markTimerAsCompleted(timer: Timer, secondsPassed: Int, startMoment: NSDate) {
        timer.completed = true
        
        let (context, fetchedTimers) = retrieveAllTimersFromCoreData()
        
        if !fetchedTimers.isEmpty {
            fetchLoop: for fetchedTimer in fetchedTimers {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedDuration = fetchedTimer.valueForKey("seconds") as Int
                let fetchedCompleted = fetchedTimer.valueForKey("completed") as Bool
                
                // Ищем таймер с таким именем, длительностью и ещё не выполненный
                // Если есть несколько таймеров с одинаковым именем и длительностью (например, перерыв 3 минуты), то отмечен выполненным будет первый найденный.
                if !fetchedCompleted && (fetchedName == timer.name) && (fetchedDuration == timer.seconds)
                {
                    fetchedTimer.setValue(true, forKey: "completed")
                    
                    // Записываем в таймер реальное пройденное время
                    fetchedTimer.setValue(secondsPassed, forKey: "seconds")
                    
                    fetchedTimer.setValue(startMoment, forKey: "startMoment")
                    fetchedTimer.setValue(NSDate(), forKey: "endMoment")
                    
                    break fetchLoop
                }
            }
            
            context.save(nil)
            
            loadTimersFromCoreData()
        }
    }
    
    func getUncompletedTimersCount() -> Int {
        var uncompletedTimersCount = 0
        
        let fetchedTimers = retrieveAllTimersFromCoreData().results
        
        if !fetchedTimers.isEmpty {
            for fetchedTimer in fetchedTimers {
                let fetchedTimerCompleted = fetchedTimer.valueForKey("completed") as Bool
                if !fetchedTimerCompleted {
                    ++uncompletedTimersCount
                }
            }
        }
        
        return uncompletedTimersCount
    }
    
}
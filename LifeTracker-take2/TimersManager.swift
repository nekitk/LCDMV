import UIKit
import CoreData

let timersManager = TimersManager()

class TimersManager: NSObject {
    
    var timers = [Timer]()
    
    var currentTimerIndex: Int?
    
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
    
    func hasNext() -> Bool {
        if currentTimerIndex && currentTimerIndex! < (getTimersCount() - 1) {
            return true
        }
        else {
            return false
        }
    }
    
    func moveToNextTimer() {
        if hasNext() {
            setCurrent(currentTimerIndex! + 1)
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
                
                timers.append(Timer(name: fetchedName, seconds: fetchedSeconds, isContinuous: fetchedIsContinuous, completed: fetchedCompleted))
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
    
    func setCurrent(index: Int) {
        currentTimerIndex = index
        currentTimer = timers[currentTimerIndex!]
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
    
    func markTimerAsCompleted(timer: Timer) {
        timer.completed = true
        
        let (context, fetchedTimers) = retrieveAllTimersFromCoreData()
        
        if !fetchedTimers.isEmpty {
            fetchLoop: for fetchedTimer in fetchedTimers {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedDuration = fetchedTimer.valueForKey("seconds") as Int
                
                //Delete timer with such a name
                if (fetchedName == timer.name) && (fetchedDuration == timer.seconds)
                {
                    fetchedTimer.setValue(true, forKey: "completed")
                    break fetchLoop
                }
            }
            
            context.save(nil)
            
            loadTimersFromCoreData()
        }
    }
    
    func deleteAllCompleted() {
        let (context, fetchedTimers) = retrieveAllTimersFromCoreData()
        
        //Fetching results
        if !fetchedTimers.isEmpty {
            for fetchedTimer in fetchedTimers {
                let fetchedTimerCompleted = fetchedTimer.valueForKey("completed") as Bool
                if fetchedTimerCompleted {
                    context.deleteObject(fetchedTimer)
                }
            }
            
            context.save(nil)
            
            loadTimersFromCoreData()
        }
    }
    
}
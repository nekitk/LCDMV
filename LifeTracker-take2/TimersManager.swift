import UIKit
import CoreData

let timersManager = TimersManager()

class TimersManager: NSObject {
    
    var timers = Timer[]()
    
    var currentTimerIndex: Int?
    
    init() {
        super.init()
        
        loadTimersFromCoreData()
    }
    
    func loadTimersFromCoreData() {
        //Clean up timers list
        timers = []
        
        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Timers")
        let results: Array = context.executeFetchRequest(request, error: nil)
        
        //Fetching results
        if !results.isEmpty {
            for fetchedTimer: AnyObject in results {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedSeconds = fetchedTimer.valueForKey("seconds") as Int
                let fetchedIsContinuous = fetchedTimer.valueForKey("isContinuous") as Bool
                
                timers.append(Timer(name: fetchedName, seconds: fetchedSeconds, isContinuous: fetchedIsContinuous))
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
        
        context.save(nil)
        
        // Reload timers list
        loadTimersFromCoreData()
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
        
        removeTimerFromCoreDataByName(timers[timerToRemoveIndex].name)

    }
    
    func removeTimerFromCoreDataByName(name: String) {
        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Timers")
        let results: Array = context.executeFetchRequest(request, error: nil)
        
        //Fetching results
        if !results.isEmpty {
            for fetchedTimer: AnyObject in results {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                
                //Delete timer with such a name
                if (fetchedName == name)
                {
                    context.deleteObject(fetchedTimer as NSManagedObject)
                }
            }
        }
        
        context.save(nil)
        
        loadTimersFromCoreData()
    }
    
}

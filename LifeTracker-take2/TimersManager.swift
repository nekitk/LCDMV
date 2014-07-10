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
        currentTimer = timers[currentTimerIndex!]
    }
    
    func removeTimer(timerToRemoveIndex: Int) {
        let removingTimerName = timers[timerToRemoveIndex].name
        let removingTimerDuration = timers[timerToRemoveIndex].seconds

        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Timers")
        let results: Array = context.executeFetchRequest(request, error: nil)
        
        //Fetching results
        if !results.isEmpty {
            fetchLoop: for fetchedTimer: AnyObject in results {
                let fetchedName = fetchedTimer.valueForKey("name") as String
                let fetchedDuration = fetchedTimer.valueForKey("seconds") as Int
                
                //Delete timer with such a name
                if (fetchedName == removingTimerName) && (fetchedDuration == removingTimerDuration)
                {
                    context.deleteObject(fetchedTimer as NSManagedObject)
                    break fetchLoop
                }
            }
            
            context.save(nil)
            
            loadTimersFromCoreData()
        }
        
    }
    
}

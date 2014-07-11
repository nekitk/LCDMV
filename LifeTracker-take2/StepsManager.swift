import UIKit
import CoreData

let stepsManager = StepManager()

struct step {
    var timerName: String
    var dateStarted: NSDate
    var durationInSec: Int
}

class StepManager: NSObject {
   
    var steps = [step]()
    
    init() {
        super.init()
        
        loadStepsFromCoreData()
    }
    
    func getStepByIndex(index: Int) -> step {
        return steps[index]
    }
    
    func getStepsCount() -> Int {
        return steps.count
    }
    
    func trackTimer(name: String, launchDate: NSDate, duration: Int) {
        if duration > 0 {
            var appDel: AppDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
            var context: NSManagedObjectContext = appDel.managedObjectContext
            var stepToBeSaved = NSEntityDescription.insertNewObjectForEntityForName("Steps", inManagedObjectContext: context) as NSManagedObject
            
            stepToBeSaved.setValue(name, forKey: "timerName")
            stepToBeSaved.setValue(launchDate, forKey: "dateStarted")
            stepToBeSaved.setValue(duration, forKey: "duration")
            
            context.save(nil)
            
            // Reload steps list
            loadStepsFromCoreData()
        }
    }
    
    func loadStepsFromCoreData() {
        //Clean up steps list
        steps = []
        
        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Steps")
        let results: Array = context.executeFetchRequest(request, error: nil)
        
        //Fetching results
        if !results.isEmpty {
            for fetchedStep: AnyObject in results {
                let fetchedTimerName = fetchedStep.valueForKey("timerName") as String
                let fetchedLaunchMoment = fetchedStep.valueForKey("dateStarted") as NSDate
                let fetchedDuration = fetchedStep.valueForKey("duration") as Int
                
                steps += step(timerName: fetchedTimerName, dateStarted: fetchedLaunchMoment, durationInSec: fetchedDuration)
            }
        }
    }
    
    func removeStep(stepToRemoveIndex: Int) {
        let removingStepTimerName = steps[stepToRemoveIndex].timerName
        let removingStepDuration = steps[stepToRemoveIndex].durationInSec
        
        //Init context
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext
        
        //Loading data from Core Data
        let request = NSFetchRequest(entityName: "Steps")
        let results: Array = context.executeFetchRequest(request, error: nil)
        
        //Fetching results
        if !results.isEmpty {
            fetchLoop: for fetchedStep: AnyObject in results {
                let fetchedTimerName = fetchedStep.valueForKey("timerName") as String
                let fetchedDuration = fetchedStep.valueForKey("duration") as Int
                
                if (fetchedTimerName == removingStepTimerName) && (fetchedDuration == removingStepDuration)
                {
                    context.deleteObject(fetchedStep as NSManagedObject)
                    break fetchLoop
                }
            }
            
            context.save(nil)
            
            loadStepsFromCoreData()
        }
    }
    
//    func removeStepsOfTimerByName(removingTimerName: String) {
//        for (stepIndex, step) in enumerate(steps) {
//            if step.timerName == removingTimerName {
//                steps.removeAtIndex(stepIndex)
//                
//                // Recursion! Without it there'll be problems with indexes
//                //  because after each removal indexes change
//                removeStepsOfTimerByName(removingTimerName)
//                return
//            }
//        }
//    }
    
}

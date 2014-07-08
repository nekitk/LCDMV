import UIKit
import CoreData

let timersManager = TimersManager()

class TimersManager: NSObject {
    
    var timers = Timer[]()
    
    var currentTimerIndex: Int?
    
    init() {
        super.init()
        
        addTimer("Test", minutes: 0, seconds: 4)
        addTimer("Quarter", minutes: 0, seconds: 15)
    }
    
    func addTimer(name: String, minutes: Int, var seconds: Int, isContinuous: Bool = false) {
        seconds += minutes * 60
        
        let timerToAdd = Timer(name: name, seconds: seconds, isContinuous: isContinuous)
        timers.append(timerToAdd)
        saveTimerToCoreData(timerToAdd)
    }
    
    func saveTimerToCoreData(timerToAdd: Timer) {
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate) as AppDelegate
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var timerToBeSaved = NSEntityDescription.insertNewObjectForEntityForName("Timers", inManagedObjectContext: context) as NSManagedObject
        
        timerToBeSaved.setValue(timerToAdd.name, forKey: "name")
        timerToBeSaved.setValue(timerToAdd.seconds, forKey: "seconds")
        timerToBeSaved.setValue(timerToAdd.isContinuous, forKey: "isContinuous")
        
        context.save(nil)
        
        println(timerToBeSaved)
        println("Saved!")
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
        timers.removeAtIndex(timerToRemoveIndex)
    }
    
//    func getTimerIndex(timer timerToFind: Timer) -> Int? {
//        for (timerIndex, timer) in enumerate(timers) {
//            if timerToFind == timer {
//                return timerIndex
//            }
//        }
//        
//        return nil
//    }
    
}

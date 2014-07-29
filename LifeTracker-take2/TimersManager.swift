import UIKit
import CoreData

let timersManager = TimersManager()

var currentTimer: Timer!

class TimersManager: NSObject, Printable {
    
    private var context: NSManagedObjectContext!
    
    private var timers = [Timer]()
    
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
        
        let documentName = "DataBase"
        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let documentURL = applicationDocumentsDirectory.URLByAppendingPathComponent(documentName)
        let document = UIManagedDocument(fileURL: documentURL)
        let options: Dictionary<String, Bool> = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        document.persistentStoreOptions = options
        
        if NSFileManager.defaultManager().fileExistsAtPath(documentURL.path) {
            //Документ существует, открываем
            document.openWithCompletionHandler({
                (success) -> Void in
                if success {
                    self.documentIsReady(document)
                }
                else {
                    println("Can't open file.")
                }
                })
        } else {
            //Документа нет, создаём
            document.saveToURL(documentURL, forSaveOperation: UIDocumentSaveOperation.ForCreating, completionHandler: {
                (success) -> Void in
                if success {
                    self.documentIsReady(document)
                }
                else {
                    println("Can't save file.")
                }
                })
        }
    }
    
    func documentIsReady(document: UIManagedDocument) {
        switch document.documentState {
        case UIDocumentState.Normal:
            self.context = document.managedObjectContext
            loadTimers()
        default:
            println("It's something wrong with document.")
        }
    }
    
    func loadTimers() {
        let request = NSFetchRequest(entityName: "Timers")
        request.returnsObjectsAsFaults = false
        timers = context.executeFetchRequest(request, error: nil) as [Timer]
    }
    
    func isReady() -> Bool {
        return context != nil
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
        let newTimer = NSEntityDescription.insertNewObjectForEntityForName("Timers", inManagedObjectContext: context) as Timer
        
        newTimer.name = name
        newTimer.seconds = Int64(minutes * 60 + seconds)
        newTimer.isContinuous = isContinuous
        newTimer.completed = false
        
        timers.append(newTimer)
    }
    
    func removeTimer(timerToRemoveIndex: Int) {
        let timerToRemove = timers.removeAtIndex(timerToRemoveIndex)
        context.deleteObject(timerToRemove)
    }
    
    
    // Отмечаем как выполненный
    func markTimerAsCompleted(timer: Timer, secondsPassed: Int, startMoment: NSDate) {
        timer.completed = true
        timer.seconds = Int64(secondsPassed)
        timer.startMoment = startMoment
        timer.endMoment = NSDate()
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
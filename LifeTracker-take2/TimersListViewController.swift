import UIKit

@objc(TimersListViewController) class TimersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var timersTable : UITableView
    
    // Reload data on view appearance
    override func viewWillAppear(animated: Bool) {
        timersTable.reloadData()
    }
    
    // UITableViewDataSource implementation
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let timersCount = timersManager.getTimersCount()
        if timersCount == 0 {
            return 0
        }
        else {
            return timersManager.getTimersCount() + 1
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell!
        if indexPath.row == timersManager.getTimersCount() {
            cell = timersTable.dequeueReusableCellWithIdentifier("DeleteAllCompletedPrototypeCell", forIndexPath: indexPath) as UITableViewCell
        }
        else {
            let timer = timersManager.getTimerByIndex(indexPath.row)
            
            // В зависимости от того, выполнена задача или ещё нет, по-разному оформляем её клетку
            let cellIdentifier: String = timer.completed ? "CompletedTimerPrototypeCell" : "TimerPrototypeCell"
            cell = timersTable.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel.text = timer.name
            
            let secondsWithoutMinutes = timer.seconds % 60
            let secondsString = secondsWithoutMinutes == 0 ? "" : " \(secondsWithoutMinutes) sec"
            cell.detailTextLabel.text = "\(timer.seconds / 60) min\(secondsString)"
            
            if timer.isContinuous {
                cell.detailTextLabel.text = cell.detailTextLabel.text + " (cont.)"
            }
        }
        
        return cell
    }
    
    // Cell click handling. Shoud be TableView's delegate to work.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        // Save clicked timer to current
        timersManager.setCurrent(indexPath.row)
        
        // Move to current timer tab
        self.tabBarController.selectedIndex = 1
    }
    
    // Timer deletion
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            timersManager.removeTimer(indexPath.row)
            timersTable.reloadData()
        }
    }
    
    // Back transition from adding timer screen
    @IBAction func unwindToTimers(segue: UIStoryboardSegue) {
        
    }
    
    // Удалить все таймеры
    //todo: окно подтверждения
    @IBAction func deleteAllCompletedTimers(sender: AnyObject) {
        timersManager.deleteAllCompleted()
        timersTable.reloadData()
    }
    
}

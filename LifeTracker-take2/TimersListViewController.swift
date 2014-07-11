import UIKit

class TimersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var timersTable : UITableView
    
    // Reload data on view appearance
    override func viewWillAppear(animated: Bool) {
        timersTable.reloadData()
    }
    
    // UITableViewDataSource implementation
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return timersManager.timers.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: nil)
        
        let timer = timersManager.timers[indexPath.row]
        
        cell.text = timer.name
        
        let secondsWithoutMinutes = timer.seconds % 60
        let secondsString = secondsWithoutMinutes == 0 ? "" : " \(secondsWithoutMinutes) sec"
        cell.detailTextLabel.text = "\(timer.seconds / 60) min\(secondsString)"
        
        if timer.isContinuous {
            cell.detailTextLabel.text = cell.detailTextLabel.text + " (cont.)"
        }
        
        return cell
    }
    
    // Cell click handling. Shoud be TableView's delegate to work.
    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        
        // Save clicked timer to current
        timersManager.setCurrent(indexPath.row)
        
        // Move to current timer tab
        self.tabBarController.selectedIndex = 1
        
        return false
    }
    
    // Timer deletion
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            timersManager.removeTimer(indexPath.row)
            timersTable.reloadData()
        }
    }
    
}

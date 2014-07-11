import UIKit

class StepsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var stepsTable: UITableView
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return stepsManager.getStepsCount()
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let stepCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        
        let step = stepsManager.getStepByIndex(indexPath.row)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        
        let dateEnded = step.dateStarted.dateByAddingTimeInterval(NSTimeInterval(step.durationInSec))
        
        stepCell.textLabel.text = "\(dateFormatter.stringFromDate(step.dateStarted)) - \(dateFormatter.stringFromDate(dateEnded)) \(step.timerName)"
        
        let minutes = step.durationInSec / 60
        let seconds = step.durationInSec % 60
        
        if minutes < 3 && seconds != 0 {
            stepCell.detailTextLabel.text = "\(minutes)m \(seconds)s"
        }
        else {
            stepCell.detailTextLabel.text = "\(minutes)m"
        }
        
        return stepCell
    }
    
    override func viewWillAppear(animated: Bool) {
        stepsTable.reloadData()
        
        // Select and scroll to latest step
        let stepsCount = stepsManager.getStepsCount()
        if stepsCount > 0 {
            let lastStepIndexPath = NSIndexPath(forRow: stepsCount - 1, inSection: 0)
            stepsTable.selectRowAtIndexPath(lastStepIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        }
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            stepsManager.removeStep(indexPath.row)
            stepsTable.reloadData()
        }
    }
    
}

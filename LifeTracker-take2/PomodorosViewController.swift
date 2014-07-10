import UIKit

class StepsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var stepsTable: UITableView
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return stepsManager.steps.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let stepCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        
        let step = stepsManager.steps[indexPath.row]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        
        stepCell.text = "\(dateFormatter.stringFromDate(step.dateStarted)) \(step.timer.name)"
        
        let minutes = step.durationInSec / 60
        let seconds = step.durationInSec % 60
        stepCell.detailTextLabel.text = "\(minutes)m \(seconds)s"
        
        return stepCell
    }
    
    override func viewWillAppear(animated: Bool) {
        stepsTable.reloadData()
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            stepsManager.steps.removeAtIndex(indexPath.row)
            stepsTable.reloadData()
        }
    }
    
}

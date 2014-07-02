import UIKit

class PomodorosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var pomodorosTable: UITableView
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return pomodoroManager.pomodoros.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let pomodoroCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
        let pomodoro = pomodoroManager.pomodoros[indexPath.row]
        let timer = timersManager.timers[pomodoro.timerIndex]
        
        pomodoroCell.text = "\(timer.name): \(pomodoro.durationInSec) sec"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        pomodoroCell.detailTextLabel.text = "Started at \(dateFormatter.stringFromDate(pomodoro.dateStarted))"
        
        return pomodoroCell
    }
    
    override func viewWillAppear(animated: Bool) {
        pomodorosTable.reloadData()
    }
    
}

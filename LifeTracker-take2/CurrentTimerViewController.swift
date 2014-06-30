import UIKit

class CurrentTimerViewController: UIViewController {

    @IBOutlet var txtName: UILabel
    @IBOutlet var txtTime: UILabel
    
    var interval: Int = 0
    var ticked = 0
    var scheduledTimer: NSTimer? = nil
    var isRunning = false
    
    @IBAction func runButtonClick() {
        if !isRunning {
            scheduledTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            isRunning = true
            updateTimeLabel()
        }
    }
    
    func updateTime() {
        if ++ticked >= interval {
            scheduledTimer?.invalidate()
            txtTime.text = "Finished"
            isRunning = false
            ticked = 0
        }
        else {
            updateTimeLabel()
        }
    }
    
    func updateTimeLabel() {
        txtTime.text = String(interval - ticked)
    }
    
    @IBAction func pauseButtonClick() {
        if isRunning {
            scheduledTimer?.invalidate()
            isRunning = false
        }
    }
    
    @IBAction func resetButtonClick() {
        scheduledTimer?.invalidate()
        ticked = 0
        isRunning = false
        updateTimeLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        let timer = timersManager.getCurrent()
        if timer {
            txtName.text = timer.name
            interval = 60 * timer.minutes + timer.seconds
            updateTimeLabel()
        }
    }

}
import UIKit

// Глобальная переменная, чтобы не заморачиваться
var startFlowRightNow: Bool = false

class AddTimerViewController: UIViewController {

    @IBOutlet var txtName : UITextField
    @IBOutlet var txtMinutes : UITextField
    @IBOutlet var txtSeconds : UITextField
    @IBOutlet var boxContinuous: UISwitch
    
    var timerWasAdded: Bool = false
    
    @IBAction func addAndStartButtonClick() {
        startFlowRightNow = true
        addButtonClick()
    }
    
    @IBAction func addButtonClick() {
        let name = txtName.text
        let minutes = txtMinutes.text.toInt()
        let seconds = txtSeconds.text.toInt()
        
        if !name.isEmpty {
            timersManager.addTimer(
                name,
                minutes: (minutes ? minutes! : 0),
                seconds: (seconds ? seconds! : 0),
                isContinuous: boxContinuous.on
            )
            
            timerWasAdded = true
            
            // Clear fields
            txtName.text = ""
            txtMinutes.text = ""
            txtSeconds.text = ""
            boxContinuous.on = false
            self.view.endEditing(true)
            
            //todo move back only if timer is added
        }
    }
    
    @IBAction func setPredefinedTimeClick(sender: AnyObject) {
        let buttonClicked = sender as UIButton
        let buttonName = buttonClicked.titleLabel.text
        
        if let timeToSet = buttonName.toInt() {
            txtMinutes.text = String(timeToSet)
            
            if timeToSet >= 8 {
                boxContinuous.on = true
            }
            else {
                boxContinuous.on = false
            }
        }
    }
    
    // Hide keyboard on touch
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
}

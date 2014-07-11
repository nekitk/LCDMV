import UIKit

class AddTimerViewController: UIViewController {

    @IBOutlet var txtName : UITextField
    @IBOutlet var txtMinutes : UITextField
    @IBOutlet var txtSeconds : UITextField
    @IBOutlet var boxContinuous: UISwitch
    
    @IBAction func addButtonClick() {
        let name = txtName.text
        let minutes = txtMinutes.text.toInt()
        let seconds = txtSeconds.text.toInt()
        
        if !name.isEmpty && (minutes || seconds) {
            timersManager.addTimer(
                name,
                minutes: (minutes ? minutes! : 0),
                seconds: (seconds ? seconds! : 0),
                isContinuous: boxContinuous.on
            )
            
            // Clear fields
            txtName.text = ""
            txtMinutes.text = ""
            txtSeconds.text = ""
            boxContinuous.on = false
            self.view.endEditing(true)
            
            //todo move back only if timer is added
        }
    }
    
    // Hide keyboard on touch
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
}

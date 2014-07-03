import UIKit

class AddTimerViewController: UIViewController {

    @IBOutlet var txtName : UITextField
    @IBOutlet var txtMinutes : UITextField
    @IBOutlet var txtSeconds : UITextField
    @IBOutlet var boxContinuos: UISwitch
    
    @IBAction func addButtonClick() {
        let name = txtName.text
        let minutes = txtMinutes.text.toInt()
        let seconds = txtSeconds.text.toInt()
        
        if !name.isEmpty && (minutes || seconds) {
            timersManager.addTimer(
                name,
                minutes: (minutes ? minutes! : 0),
                seconds: (seconds ? seconds! : 0),
                isContinuos: boxContinuos.on
            )
            
            // Clear fields
            txtName.text = ""
            txtMinutes.text = ""
            txtSeconds.text = ""
            boxContinuos.on = false
            self.view.endEditing(true)
            
            // Move to first tab
            self.tabBarController.selectedIndex = 0
        }
    }
    
    // Hide keyboard on touch
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
}

import UIKit

class AddTimerViewController: UIViewController {

    @IBOutlet var txtName : UITextField
    @IBOutlet var txtMinutes : UITextField
    @IBOutlet var txtSeconds : UITextField
    
    @IBAction func addButtonClick() {
        let name = txtName.text
        let minutes = txtMinutes.text.toInt()
        let seconds = txtSeconds.text.toInt()
        
        if !name.isEmpty && minutes {
            timersManager.addTimer(name, minutes: minutes!, seconds: (seconds ? seconds! : 0))
            
            // Clear fields
            txtName.text = ""
            txtMinutes.text = ""
            txtSeconds.text = ""
            
            // Move to first tab
            self.tabBarController.selectedIndex = 0
        }
    }
    
    // Hide keyboard on touch
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
}

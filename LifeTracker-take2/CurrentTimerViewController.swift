import UIKit
import AVFoundation

class CurrentTimerViewController: UIViewController {

    @IBOutlet var txtName: UILabel
    @IBOutlet var txtTime: UILabel
    
    var soundPlayer: AVAudioPlayer!
    
    let finishSoundName = "mario.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mario", ofType: "wav"))
    
    var timerTimeInSec: Int = 0
    var launchMoment: NSDate?
    
    //todo nstimer: schedule at view appear and call updateTime()
    
    @IBAction func runButtonClick() {
        if !launchMoment {
            launchMoment = NSDate()
            updateTime()
            scheduleNotification()
        }
    }
    
    func scheduleNotification() {
        let timerEndNotification = UILocalNotification()
        timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(timerTimeInSec))
        timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
        timerEndNotification.alertBody = "Timer ended"
        timerEndNotification.soundName = finishSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
    }
    
    func updateTime() {
        let secondsLeft = NSDate().timeIntervalSinceDate(launchMoment!)
        txtTime.text = String(secondsLeft)
    }
    
    @IBAction func pauseButtonClick() {

    }
    
    @IBAction func resetButtonClick() {

    }
    
    override func viewDidLoad() {
        // Initializing audio player
        soundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        soundPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        let timer = timersManager.getCurrent()
        if timer {
            txtName.text = timer.name
            timerTimeInSec = 60 * timer.minutes + timer.seconds
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }

}
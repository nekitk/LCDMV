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
    
    var refreshTimer: NSTimer!
    
    @IBAction func runButtonClick() {
        if !launchMoment {
            launchMoment = NSDate()
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            scheduleNotification()
        }
    }
    
    // iOs 7 only. iOs 8 requires notification registration
    
    func scheduleNotification() {
        let timerEndNotification = UILocalNotification()
        timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(timerTimeInSec))
        timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
        timerEndNotification.alertBody = "Timer ended"
        timerEndNotification.soundName = finishSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
    }
    
    func updateTime() {
        let secondsPassed = launchMoment ? NSDate().timeIntervalSinceDate(launchMoment!) : 0
        let secondsLeft = NSTimeInterval(timerTimeInSec) - secondsPassed
        
        if secondsLeft > 0 {
            txtTime.text = String(Int(secondsLeft))
        }
        else {
            resetTimer()
            
            // Finish message and sound
            txtTime.text = "Finished"
            soundPlayer.play()
        }
    }
    
    func resetTimer() {
        refreshTimer.invalidate()
        launchMoment = nil
    }
    
    @IBAction func pauseButtonClick() {

    }
    
    @IBAction func resetButtonClick() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        resetTimer()
        updateTime()
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
            updateTime()
        }
    }

}
import UIKit
import AVFoundation

class CurrentTimerViewController: UIViewController {

    @IBOutlet var txtName: UILabel
    @IBOutlet var txtTime: UILabel
    
    var finishSoundPlayer: AVAudioPlayer!
    let finishSoundName = "mario.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mario", ofType: "wav"))
    
    var startSoundPlayer: AVAudioPlayer!
    let startSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("start", ofType: "wav"))
    
    var timerTimeInSec: Int = 0
    var launchMoment: NSDate?
    
    var refreshTimer: NSTimer!
    
    @IBAction func runButtonClick() {
        if !launchMoment {
            startSoundPlayer.play()
            
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
            let minutesToShow = Int(secondsLeft) / 60
            let secondsToShow = Int(secondsLeft) % 60
            var secondsString: String!
            if secondsToShow < 10 {
                secondsString = "0\(secondsToShow)"
            }
            else {
                secondsString = String(secondsToShow)
            }
            txtTime.text = "\(minutesToShow):\(secondsString)"
        }
        else {
            pomodoroManager.trackTimer(timersManager.currentTimer!, launchDate: launchMoment!)
            
            resetTimer()
            
            // Finish message and sound
            txtTime.text = "Finished"
            finishSoundPlayer.play()
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
        // Initializing sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        finishSoundPlayer.prepareToPlay()
        
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        startSoundPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let timer = timersManager.getCurrent() {
            txtName.text = timer.name
            timerTimeInSec = 60 * timer.minutes + timer.seconds

            updateTime()
        }
    }

}
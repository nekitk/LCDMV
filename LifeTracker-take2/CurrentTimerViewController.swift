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
    var secondsToGo: Int!
    var launchMoment: NSDate?
    var originalLaunchMoment: NSDate?
    
    var isPaused = false
    var secondsPassed: NSTimeInterval = 0
    var isOver = false
    
    var refreshTimer: NSTimer!
    
    @IBAction func runButtonClick() {
        
        // No launchMoment means timer is stopped
        if !launchMoment {
            startSoundPlayer.play()
            secondsToGo = timerTimeInSec
            originalLaunchMoment = NSDate()
            launchMoment = originalLaunchMoment
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            scheduleNotification()
        }
        
        if isPaused {
            startSoundPlayer.play()
            isPaused = false
            launchMoment = NSDate()
            secondsToGo = secondsToGo - Int(secondsPassed)
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            scheduleNotification()
        }
    }
    
    // iOs 7 only. iOs 8 requires notification registration
    
    func scheduleNotification() {
        let timerEndNotification = UILocalNotification()
        timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(secondsToGo))
        timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
        timerEndNotification.alertBody = "Timer ended"
        timerEndNotification.soundName = finishSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
    }
    
    func updateTime() {
        secondsPassed = launchMoment ? NSDate().timeIntervalSinceDate(launchMoment!) : 0
        var secondsLeft = secondsToGo - Int(secondsPassed)
        var prefix = ""
        
        if secondsLeft < 0 {
            secondsLeft = abs(secondsLeft)
            prefix = "+"
            
            // Play finish sound once
            if !isOver {
                isOver = true
                finishSoundPlayer.play()
            }
        }
        
        // Formatting time label
        
        let minutesToShow = secondsLeft / 60
        let secondsToShow = secondsLeft % 60
        
        // Adding zeroes to little seconds
        var secondsString: String!
        if secondsToShow < 10 {
            secondsString = "0\(secondsToShow)"
        }
        else {
            secondsString = String(secondsToShow)
        }
        
        txtTime.text = prefix + "\(minutesToShow):\(secondsString)"
    }
    
    func resetTimer() {
        refreshTimer.invalidate()
        launchMoment = nil
    }
    
    @IBAction func pauseButtonClick() {
        //todo Not working
        isPaused = true
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        refreshTimer.invalidate()
    }
    
    @IBAction func stopButtonClick() {
        // Track finished timer
        let overTimeSeconds: Int = Int(secondsPassed) - secondsToGo
        
        // If timer is not yet finished overTimeSeconds will be negative, and they will be discarded from overall timer length
        pomodoroManager.trackTimer(timersManager.currentTimer!, launchDate: originalLaunchMoment!, overTimeSeconds: overTimeSeconds)
        
        isOver = false
        isPaused = false
        
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
            secondsToGo = timerTimeInSec

            updateTime()
        }
    }

}
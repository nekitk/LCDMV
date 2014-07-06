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
    
    var currentTimer: Timer?
    
    var secondsToGo: Int!
    var launchMoment: NSDate?
    var originalLaunchMoment: NSDate?
    
    var isPaused = false
    var secondsPassed: NSTimeInterval = 0
    var isOver = false
    
    var refreshTimer: NSTimer!
    
    @IBAction func runButtonClick() {
        if currentTimer {
            // No launchMoment means timer is stopped
            if !launchMoment {
                startSoundPlayer.play()
                secondsToGo = currentTimer!.seconds
                originalLaunchMoment = NSDate()
                launchMoment = originalLaunchMoment
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
                scheduleNotification()
                
                // Prevent phone locking
                UIApplication.sharedApplication().idleTimerDisabled = true
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
        
        if secondsLeft <= 0 {
            if !isOver {
                isOver = true
                finishSoundPlayer.play()
            }

            if currentTimer!.isContinuous {
                secondsLeft = abs(secondsLeft)
                prefix = "+"
            }
            else {
                // Not continuous
                stopButtonClick()
                return
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
        if refreshTimer {
            refreshTimer.invalidate()
        }
        launchMoment = nil
        currentTimer = timersManager.getCurrent()
        
        if currentTimer {
            txtName.text = currentTimer!.name
            secondsToGo = currentTimer!.seconds
        }
        updateTime()
        
        // Enable phone locking again
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    @IBAction func pauseButtonClick() {
        if currentTimer {
            isPaused = true
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            refreshTimer.invalidate()
        }
    }
    
    @IBAction func stopButtonClick() {
        if currentTimer {
            // Track finished timer
            let overTimeSeconds: Int = Int(secondsPassed) - secondsToGo
            
            // If timer is not yet finished overTimeSeconds will be negative, and they will be discarded from overall timer length
            pomodoroManager.trackTimer(currentTimer!, launchDate: originalLaunchMoment!, overTimeSeconds: overTimeSeconds)
            
            isOver = false
            isPaused = false
            
            finishSoundPlayer.play()
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            resetTimer()
        }
    }
    
    override func viewDidLoad() {
        // Initializing sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        finishSoundPlayer.prepareToPlay()
        
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        startSoundPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        if !launchMoment {
            currentTimer = timersManager.getCurrent()
            
            if currentTimer {
                txtName.text = currentTimer!.name
                secondsToGo = currentTimer!.seconds
                updateTime()
            }
        }
    }

}
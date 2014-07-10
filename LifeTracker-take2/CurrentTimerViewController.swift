import UIKit
import AVFoundation

var currentTimer: Timer!

class CurrentTimerViewController: UIViewController {
    
    @IBOutlet var txtName: UILabel
    @IBOutlet var txtTime: UILabel
    
    @IBOutlet var runButton: UIButton
    @IBOutlet var pauseButton: UIButton
    @IBOutlet var stopButton: UIButton
    
    var finishSoundPlayer: AVAudioPlayer!
    let finishSoundName = "mario.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mario", ofType: "wav"))
    
    var startSoundPlayer: AVAudioPlayer!
    let startSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("start", ofType: "wav"))
    
    var refreshTimer: NSTimer!
    
    var overtimeRunningAllowed: Bool!

    // Store these in case timer changing
    var timerName: String!
    var totalSecondsToGo: NSTimeInterval!
    
    var firstLaunchMoment: NSDate!
    var lastLaunchMoment: NSDate!
    var secondsPassed: NSTimeInterval!
    
    // Timer states
    let TIMER_NOT_SET = 0
    let TIMER_SET_BUT_NOT_STARTED = 1
    let RUNNING = 2
    let PAUSED = 3
    let FINISHED = 4
    
    var timerState: Int?
    
    func changeStateTo(newState: Int) {
        var doChangeState = true
        
        // Check from state transitions
        if timerState {
            switch timerState! {
            
            case RUNNING:
                if newState == PAUSED || newState == FINISHED {
                    refreshTimer.invalidate()
                    
                    let secondsPassedSinceLastLaunch = NSDate().timeIntervalSinceDate(lastLaunchMoment)
                    secondsPassed = secondsPassed + secondsPassedSinceLastLaunch
                    
                    lastLaunchMoment = nil
                }
                
            default:
                break
            }
        }
        
        // Check to state transitions
        switch newState {
        
        case TIMER_NOT_SET:
            if !timerState {
                txtName.text = "Timer not set"
                txtTime.enabled = false
                setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: false, stopButtonEnabled: false)
            }
        
        case TIMER_SET_BUT_NOT_STARTED:
            // Timer not set -> Timer set: first timer setup
            // Timer set -> Timer set: changing current timer
            // Finished -> Timer set: changing finished timer
            if timerState == TIMER_NOT_SET || timerState == TIMER_SET_BUT_NOT_STARTED || timerState == FINISHED {
                txtName.text = currentTimer.name
                txtTime.enabled = true
                setButtonsEnabled(runButtonEnabled: true, pauseButtonEnabled: false, stopButtonEnabled: false)
                updateTimeLabel(currentTimer.seconds)
            }
            else {
                doChangeState = false
            }
            
        case RUNNING:
            // Timer set -> Running: first launch
            // Paused -> Running
            if timerState == TIMER_SET_BUT_NOT_STARTED || timerState == PAUSED {
                startSoundPlayer.play()
                setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: true, stopButtonEnabled: false)
                
                lastLaunchMoment = NSDate()
                
                // Set initial launch moment
                if !firstLaunchMoment {
                    firstLaunchMoment = lastLaunchMoment
                    secondsPassed = 0
                    totalSecondsToGo = NSTimeInterval(currentTimer.seconds)
                    overtimeRunningAllowed = currentTimer.isContinuous
                    timerName = currentTimer.name
                }
                
                // Schedule notifications
                scheduleNotifications()
                
                // Start ticking
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
                
                // Prevent phone locking
                UIApplication.sharedApplication().idleTimerDisabled = true
            }
            else {
                doChangeState = false
            }
            
        case PAUSED:
            if timerState == RUNNING {
                setButtonsEnabled(runButtonEnabled: true, pauseButtonEnabled: false, stopButtonEnabled: true)
                
                // Disabling local and sound notifications
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                finishSoundPlayer.stop()
            }
            else {
                doChangeState = false
            }
            
        case FINISHED:
            if timerState == RUNNING || timerState == PAUSED {
                finishSoundPlayer.play()
                txtTime.text = ":)"
                setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: false, stopButtonEnabled: false)
                
                // Enable phone locking again
                UIApplication.sharedApplication().idleTimerDisabled = false
            
                // For fixed timer: if calculated duration is bigger than it duration
                if !overtimeRunningAllowed && secondsPassed > totalSecondsToGo {
                    secondsPassed = totalSecondsToGo
                }
                
                // Track time spent
                stepsManager.trackTimer(timerName, launchDate: firstLaunchMoment, duration: Int(secondsPassed))
                
                // Reset timer
                firstLaunchMoment = nil
            }
            else {
                doChangeState = false
            }
            
        default:
            // Don't change state if it is not described
            doChangeState = false
        }
        
        // Change timer state to new state
        if doChangeState {
            timerState = newState
        }
    }
    
    func scheduleNotifications() {
        let secondsLeft = totalSecondsToGo - secondsPassed
        
        // SecondsLeft became less than 0 when timer is running overtime
        if secondsLeft > 0 {
            // Schedule sound playing
            finishSoundPlayer.playAtTime(finishSoundPlayer.deviceCurrentTime + secondsLeft)
            
            // Schedule local notification
            let timerEndNotification = UILocalNotification()
            timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: secondsLeft)
            timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
            timerEndNotification.alertBody = "Timer \(timerName) ended"
            timerEndNotification.soundName = finishSoundName
            
            UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
        }
    }
    
    func updateTime() {
        let secondsPassedSinceLastLaunch = NSDate().timeIntervalSinceDate(lastLaunchMoment)
        let secondsLeft = (totalSecondsToGo - secondsPassed) - secondsPassedSinceLastLaunch
        updateTimeLabel(Int(ceil(secondsLeft)))
        
        if !overtimeRunningAllowed && secondsLeft <= 0 {
            changeStateTo(FINISHED)
        }
    }
    
    func updateTimeLabel(var timeInSeconds: Int) {
        var prefix = ""
        if timeInSeconds < 0 {
            prefix = "+"
            timeInSeconds = abs(timeInSeconds)
        }
        
        let minutesToShow = timeInSeconds / 60
        let secondsToShow = timeInSeconds % 60
    
        // Adding zeroes to little seconds
        var secondsString: String!
        if secondsToShow < 10 {
            secondsString = "0\(secondsToShow)"
        }
        else {
            secondsString = String(secondsToShow)
        }
        
        txtTime.text = "\(prefix)\(minutesToShow):\(secondsString)"
    }

    @IBAction func runButtonClick() {
        changeStateTo(RUNNING)
    }
    
    @IBAction func pauseButtonClick() {
        changeStateTo(PAUSED)
    }
    
    @IBAction func stopButtonClick() {
        changeStateTo(FINISHED)
    }
    
    func setButtonsEnabled(#runButtonEnabled: Bool, pauseButtonEnabled: Bool, stopButtonEnabled: Bool) {
        runButton.enabled = runButtonEnabled
        pauseButton.enabled = pauseButtonEnabled
        stopButton.enabled = stopButtonEnabled
    }
    
    override func viewDidLoad() {
        // Initialize sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        finishSoundPlayer.prepareToPlay()
        
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        startSoundPlayer.prepareToPlay()
        
        changeStateTo(TIMER_NOT_SET)
    }
    
    override func viewWillAppear(animated: Bool) {
        if currentTimer {
            changeStateTo(TIMER_SET_BUT_NOT_STARTED)
        }
    }
    
}
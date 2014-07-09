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
    
    var firstLaunchMoment: NSDate!
    var lastPauseMoment: NSDate?
    var secondsBeingPaused: Int = 0
    
    // Timer states
    let TIMER_NOT_SET = 0
    let STOPPED = 1
    let RUNNING = 2
    let PAUSED = 3
    let FINISHED = 4
    
    var currentState: Int?
    
    func changeStateTo(newState: Int) {
        // Check from state transitions
        if currentState {
            switch currentState! {
            
            case RUNNING:
                refreshTimer.invalidate()
                
            case PAUSED:
                let thisPauseDuration = Int(NSDate().timeIntervalSinceDate(lastPauseMoment))
                secondsBeingPaused += thisPauseDuration
                lastPauseMoment = nil
                
            default:
                break
            }
        }
        
        // Check to state transitions
        switch newState {
        
        case TIMER_NOT_SET:
            txtName.text = "Timer not set"
            txtTime.enabled = false
            setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: false, stopButtonEnabled: false)
        
        case STOPPED:
            txtName.text = currentTimer.name
            txtTime.enabled = true
            setButtonsEnabled(runButtonEnabled: true, pauseButtonEnabled: false, stopButtonEnabled: false)
            updateTimeLabel(currentTimer.seconds)
            
        case RUNNING:
            startSoundPlayer.play()
            setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: true, stopButtonEnabled: false)
            
            // Set initial launch moment
            if !firstLaunchMoment {
                firstLaunchMoment = NSDate()
            }
            
            //todo figure out how to make it sound more synchronized
            let secondsSinceFirstLaunch = Int(NSDate().timeIntervalSinceDate(firstLaunchMoment))
            let secondsRunning = secondsSinceFirstLaunch - secondsBeingPaused
            let secondsLeft = currentTimer.seconds - secondsRunning
            
            // Schedule notifications
            scheduleNotifications(secondsToGo: secondsLeft)
            
            // Start ticking
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            
            // Prevent phone locking
            UIApplication.sharedApplication().idleTimerDisabled = true
            
        case PAUSED:
            //todo Allow stop when Paused
            setButtonsEnabled(runButtonEnabled: true, pauseButtonEnabled: false, stopButtonEnabled: false)
            
            // Disabling local and sound notifications
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            finishSoundPlayer.stop()
            
            lastPauseMoment = NSDate()
            
        case FINISHED:
            txtTime.text = ":)"
            setButtonsEnabled(runButtonEnabled: false, pauseButtonEnabled: false, stopButtonEnabled: false)
            
            // Enable phone locking again
            UIApplication.sharedApplication().idleTimerDisabled = false
        
            // Track time spent
            pomodoroManager.trackTimer(currentTimer, launchDate: firstLaunchMoment, duration: currentTimer.seconds)
            
            // Reset timer
            secondsBeingPaused = 0
            firstLaunchMoment = nil
            lastPauseMoment = nil
            
        default:
            break
        }
        currentState = newState
    }
    
    func scheduleNotifications(var #secondsToGo: Int) {
        // Schedule sound playing
        finishSoundPlayer.playAtTime(finishSoundPlayer.deviceCurrentTime + NSTimeInterval(secondsToGo))
        
        // Schedule local notification
        let timerEndNotification = UILocalNotification()
        timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(secondsToGo))
        timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
        timerEndNotification.alertBody = "Timer \(currentTimer.name) ended"
        timerEndNotification.soundName = finishSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
    }
    
    func updateTime() {
        //todo uncopypaste it
        let secondsSinceFirstLaunch = Int(NSDate().timeIntervalSinceDate(firstLaunchMoment))
        let secondsRunning = secondsSinceFirstLaunch - secondsBeingPaused
        let secondsLeft = currentTimer.seconds - secondsRunning
        
        updateTimeLabel(secondsLeft)
        
        if secondsLeft <= 0 {
            changeStateTo(FINISHED)
        }
    }
    
    func updateTimeLabel(timeInSeconds: Int) {
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
        
        txtTime.text = "\(minutesToShow):\(secondsString)"
    }

    @IBAction func runButtonClick() {
        if currentState == STOPPED || currentState == PAUSED {
            changeStateTo(RUNNING)
        }
    }
    
    @IBAction func pauseButtonClick() {
        if currentState == RUNNING {
            changeStateTo(PAUSED)
        }
    }
    
    @IBAction func stopButtonClick() {
        if currentState == PAUSED {
            changeStateTo(FINISHED)
        }
    }
    
    func setButtonsEnabled(#runButtonEnabled: Bool, pauseButtonEnabled: Bool, stopButtonEnabled: Bool) {
        runButton.enabled = runButtonEnabled
        pauseButton.enabled = pauseButtonEnabled
        stopButton.enabled = stopButtonEnabled
    }
    
    override func viewDidLoad() {
        changeStateTo(TIMER_NOT_SET)
        
        // Initialize sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        finishSoundPlayer.prepareToPlay()
        
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        startSoundPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Timer not set -> Stopped: first timer setup
        // Stopped -> Stopped: changing current timer
        // Finished -> Stopped: changing finished timer
        
        if currentState == TIMER_NOT_SET || currentState == STOPPED || currentState == FINISHED {
            if currentTimer {
                changeStateTo(STOPPED)
            }
        }
    }
    
}
import UIKit
import AVFoundation

var currentTimer: Timer!

class CurrentTimerViewController: UIViewController {
    
    @IBOutlet var txtName: UILabel
    @IBOutlet var txtTime: UILabel
    
    @IBOutlet var runButton: UIButton
    @IBOutlet var pauseButton: UIButton
    @IBOutlet var stopButton: UIButton
    @IBOutlet var nextButton: UIButton
    
    var finishSoundPlayer: AVAudioPlayer!
    let finishSoundName = "tone.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tone", ofType: "wav"))
    
    var startSoundPlayer: AVAudioPlayer!
    let startSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gong", ofType: "wav"))
    
    var refreshTimer: NSTimer!
    
    // Better not to use optionals with Bools
    // if optionalBool checks optional, not the value of Bool itself
    var overtimeRunningAllowed: Bool = false
    var isRunningOvertime: Bool = false

    // Store these in case timer changing
    var timerName: String!
    var totalSecondsToGo: NSTimeInterval!
    
    var firstLaunchMoment: NSDate!
    var lastLaunchMoment: NSDate!
    var secondsPassed: NSTimeInterval!
    
    var timerState: Int?
    
    // Timer states
    let TIMER_NOT_SET = 0
    let TIMER_SET_BUT_NOT_STARTED = 1
    let RUNNING = 2
    let PAUSED = 3
    let FINISHED = 4
    
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
                    
                    // Disabling local notifications
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
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
                enableTheseButtons()
            }
        
        case TIMER_SET_BUT_NOT_STARTED:
            // Timer not set -> Timer set: first timer setup
            // Timer set -> Timer set: changing current timer
            // Finished -> Timer set: changing finished timer
            if timerState == TIMER_NOT_SET || timerState == TIMER_SET_BUT_NOT_STARTED || timerState == FINISHED {
                txtName.text = currentTimer.name
                txtTime.enabled = true
                enableTheseButtons(runButtonEnabled: true)
                updateTimeLabel(currentTimer.seconds)
            }
            else {
                doChangeState = false
            }
            
        case RUNNING:
            // Timer set -> Running: first launch
            // Paused -> Running
            if timerState == TIMER_SET_BUT_NOT_STARTED || timerState == PAUSED {
                
                enableTheseButtons(pauseButtonEnabled: true, stopButtonEnabled: true)
                
                lastLaunchMoment = NSDate()
                

                if !firstLaunchMoment {
                    firstLaunchMoment = lastLaunchMoment
                    
                    secondsPassed = 0
                    isRunningOvertime = false
                    
                    // При первом запуске копируем все данные таймера.
                    // В таком случае нам не страшно удаление или изменение
                    // Это никак не повлияет на тиканье.
                    totalSecondsToGo = NSTimeInterval(currentTimer.seconds)
                    overtimeRunningAllowed = currentTimer.isContinuous
                    timerName = currentTimer.name
                    
                    // Сразу отмечаем как завершённый (на тот случай, если его вдруг на ходу сменят на другой)
                    timersManager.markTimerAsCompleted(currentTimer)
                }
                
                // 0 секунд -- это не таймер, а туду. Пока так.
                if totalSecondsToGo != 0 {
                    startSoundPlayer.play()
                }
                
                scheduleNotifications()
                
                // Начинаем тикать
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
                
                // Prevent phone locking
                UIApplication.sharedApplication().idleTimerDisabled = true
            }
            else {
                doChangeState = false
            }
            
        case PAUSED:
            if timerState == RUNNING {
                enableTheseButtons(runButtonEnabled: true, stopButtonEnabled: true)
            }
            else {
                doChangeState = false
            }
            
        case FINISHED:
            if timerState == RUNNING || timerState == PAUSED {
                
                txtTime.text = ":)"
                
                if timersManager.currentTimerIndex && timersManager.hasNext() {
                    enableTheseButtons(nextButtonEnabled: true)
                }
                else {
                    enableTheseButtons()
                }
                
                // Enable phone locking again
                UIApplication.sharedApplication().idleTimerDisabled = false
            
                // Flooring seconds to compare with total time to go and to track it
                secondsPassed = floor(secondsPassed)
                
                // For fixed timer: if calculated duration is bigger than it duration
                // This means that timer transits to FINISHED after actual finishing moment
                // It can occur if phone is locked when timer has finished
                if !overtimeRunningAllowed && secondsPassed > totalSecondsToGo {
                    secondsPassed = totalSecondsToGo
                }
                else {
                    // Play sound once for NOT ENDLESS timer
                    // Play sound only if timer transits to FINISHED state now (not after device unlocking)
                    finishSoundPlayer.play()
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
        
        var timeToShow = Int(ceil(secondsLeft))
        
        // overtime not allowed -> Finished
        // overtime allowed -> play sound once and continue ticking
        if secondsLeft <= 0 {
            if overtimeRunningAllowed {
                
                // Если время истекло, а таймер бесконечный, то показываем сколько времени прошло всего с самого начала
                timeToShow = Int(totalSecondsToGo) + abs(Int(secondsLeft))
                
                // This bool is needed to play sound only once
                if !isRunningOvertime {
                    isRunningOvertime = true
                    
                    // Play sound once for ENDLESS timer
                    // Play finish sound only if time ran out now (not when phone was locked)
                    if ceil(secondsLeft) >= 0 {
                        finishSoundPlayer.play()
                    }
                }
            }
            else {
                changeStateTo(FINISHED)
            }
        }
        
        updateTimeLabel(timeToShow)
    }
    
    func updateTimeLabel(var timeInSeconds: Int) {
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
        changeStateTo(RUNNING)
    }
    
    @IBAction func pauseButtonClick() {
        changeStateTo(PAUSED)
    }
    
    @IBAction func stopButtonClick() {
        changeStateTo(FINISHED)
    }
    
    @IBAction func nextButtonClick(sender: AnyObject) {
        timersManager.moveToNextTimer()
        changeStateTo(TIMER_SET_BUT_NOT_STARTED)
    }
    
    func enableTheseButtons(runButtonEnabled: Bool = false, pauseButtonEnabled: Bool = false, stopButtonEnabled: Bool = false, nextButtonEnabled: Bool = false) {
        runButton.enabled = runButtonEnabled
        pauseButton.enabled = pauseButtonEnabled
        stopButton.enabled = stopButtonEnabled
        nextButton.hidden = !nextButtonEnabled
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
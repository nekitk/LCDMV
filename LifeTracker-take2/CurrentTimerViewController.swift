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
    @IBOutlet var doneButton: UIButton
    @IBOutlet var goBackButton: UIButton
    @IBOutlet var quitButton: UIBarButtonItem
    @IBOutlet var showHideTimeButton: UIButton
    
    @IBOutlet var timerControls: UIView
    
    var finishSoundPlayer: AVAudioPlayer!
    let finishSoundName = "tone.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tone", ofType: "wav"))
    
    var startSoundPlayer: AVAudioPlayer!
    let startSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gong", ofType: "wav"))
    
    var refreshTimer: NSTimer!
    
    // Better not to use optionals with Bools
    // if optionalBool checks optional, not the value of Bool itself
    var timerIsContinuous: Bool = false
    var isRunningOvertime: Bool = false

    // Store these in case timer changing
    var timerName: String!
    var totalSecondsToGo: NSTimeInterval!
    
    var firstLaunchMoment: NSDate!
    var lastLaunchMoment: NSDate!
    var secondsPassed: NSTimeInterval = 0
    
    var timerState: Int?
    
    // Timer states
    let TIMER_NOT_SET = 0
    let TIMER_SET_BUT_NOT_STARTED = 1
    let RUNNING = 2
    let PAUSED = 3
    let FINISHED = 4
    
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
    }
    
    @IBAction func showHideButtonClick() {
        txtTime.hidden = !txtTime.hidden
    }
    
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
                enableTheseButtons(runButtonEnabled: true)
                txtTime.enabled = true
                
                // Копируем все данные таймера.
                // В таком случае нам не страшно удаление или изменение
                // Это никак не повлияет на тиканье.
                totalSecondsToGo = NSTimeInterval(currentTimer.seconds)
                timerIsContinuous = currentTimer.isContinuous
                timerName = currentTimer.name
                
                txtName.text = currentTimer.name
                updateTimeLabel(Int(totalSecondsToGo))
                
                // Если время = 0 и конечный, то это туду-задача
                if currentTimer.seconds == 0 && !currentTimer.isContinuous {
                    txtTime.hidden = true
                    showHideTimeButton.hidden = true
                    timerControls.hidden = true
                    
                    doneButton.hidden = false
                }
                // А иначе это таймер
                else {
                    txtTime.hidden = false
                    showHideTimeButton.hidden = false
                    timerControls.hidden = false
                    
                    doneButton.hidden = true
                }
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
                }
                
                // Если 0 секунд и не бесконечный, то это не таймер, а туду, и звук играть не надо. Пока так.
                if timerIsContinuous || totalSecondsToGo != 0 {
                    startSoundPlayer.play()
                }
                
                scheduleNotifications()
                
                // Начинаем тикать
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
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
                
                txtTime.hidden = false
                txtTime.text = ":)"
                showHideTimeButton.hidden = true
                
                var secondsToTrack: Int!
                
                // Если таймер бесконечный, то трэкаем полное время, сколько набежало.
                // Если таймер завершили раньше положенного, то тоже трэкаем сколько набежало.
                if currentTimer.isContinuous || secondsPassed < totalSecondsToGo {
                    secondsToTrack = Int(secondsPassed)
                }
                // А если это обычный таймер, который вовремя закончился, то трэкаем его полное время. Потому что набежавшее время может быть завышенным после анлока телефона.
                //todo Пожалуй, стоит заморочиться и правильно сохранять secondsPassed в таких случаях, чтобы потом не городить кучу вот таких проверок.
                else {
                    secondsToTrack = Int(totalSecondsToGo)
                }
                
                timersManager.markTimerAsCompleted(currentTimer, secondsPassed: secondsToTrack)
                
                // Показываем кнопку "Следующий", если он наличествует
                if timersManager.hasNextUncompleted() {
                    enableTheseButtons(nextButtonEnabled: true)
                }
                else {
                    enableTheseButtons(goBackButtonEnabled: true)
                }
                
                // Flooring seconds to compare with total time to go
                secondsPassed = floor(secondsPassed)
                
                // Цель всего нижеследующего шаманства в том, чтобы звук окончания играл только в тех случаях, когда приложение открыто. И не играл в тех случаях, когда таймер истёк в то время, пока телефон был заблокирован.
                // Если это бесконечный таймер, то в завершённое состояние он переходит только по велению пользователя. А значит звук нужно играть всегда в таких случаях.
                if timerIsContinuous {
                    finishSoundPlayer.play()
                }
                // Если же это конечный таймер, то играть звук нужно только в том случае, когда прошедшее время меньше или равно назначенному. Если оно больше, то это свидетельствует о том, что приложение не было активно в то время, когда истёк таймер. При этом пользователю пришло оповещение со звуком, так что не нужно его проигрывать при открытии приложения, это раздражает.
                else if secondsPassed <= totalSecondsToGo {
                    finishSoundPlayer.play()
                }
                
                // Сбрасываем состояние таймера
                firstLaunchMoment = nil
                secondsPassed = 0
                isRunningOvertime = false
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

            // Schedule main notification
            let timerEndNotification = UILocalNotification()
            timerEndNotification.fireDate = NSDate(timeIntervalSinceNow: secondsLeft)
            timerEndNotification.timeZone = NSTimeZone.defaultTimeZone()
            timerEndNotification.alertBody = "\(timerName) усё."
            timerEndNotification.soundName = finishSoundName
            
            UIApplication.sharedApplication().scheduleLocalNotification(timerEndNotification)
            
            // Дополнительное оповещение на тот случай, если про таймер забыли
            
            // Таймаут 3 минуты
            let timeout = NSTimeInterval(180)
            
            let secondNotification = UILocalNotification()
            secondNotification.fireDate = NSDate(timeIntervalSinceNow: secondsLeft + timeout)
            secondNotification.timeZone = NSTimeZone.defaultTimeZone()
            secondNotification.alertBody = "Куку!"
            secondNotification.soundName = finishSoundName
            
            UIApplication.sharedApplication().scheduleLocalNotification(secondNotification)
        }
    }
    
    func updateTime() {
        let secondsPassedSinceLastLaunch = NSDate().timeIntervalSinceDate(lastLaunchMoment)
        let secondsLeft = Int(ceil((totalSecondsToGo - secondsPassed) - secondsPassedSinceLastLaunch))
        
        // Заморачиваемся на то, какое время показывать на экране
        
        var timeToShow: Int!
        
        if timerIsContinuous && isRunningOvertime {
            // Если таймер бесконечный и превысил свой лимит, то показываем, сколько времени прошло с его запуска
            timeToShow = Int(secondsPassed + secondsPassedSinceLastLaunch)
        }
        else {
            // В остальных случаях показываем, сколько осталось
            timeToShow = secondsLeft
        }
        
        updateTimeLabel(timeToShow)
        
        
        // overtime not allowed -> Finished
        // overtime allowed -> play sound once and continue ticking
        if secondsLeft <= 0 {
            if timerIsContinuous {
                
                // This bool is needed to play sound only once
                if !isRunningOvertime {
                    isRunningOvertime = true
                    
                    // Для бесконечного таймера играем звук в том случае, когда соблюдены оба условия:
                    // 1. Это не таймер с нулевой длительностью. Для нулевого таймера звук играть не надо, он просто начинает тикать с нуля вверх.
                    // 2. Таймер истёк прямо сейчас, а не в то время, когда телефон был заблокирован. Об этом свидетельствует то, что количество оставшихся секунд сравнялось нулю.
                    if totalSecondsToGo != 0 && secondsLeft == 0{
                        finishSoundPlayer.play()
                    }
                }
            }
            else {
                changeStateTo(FINISHED)
                
                // Выходим, чтобы не обновилась надпись со временем, в которой рисуется смайлик
                return
            }
        }
    }
    
    func updateTimeLabel(timeToShow: Int) {
        let minutesToShow = timeToShow / 60
        let secondsToShow = timeToShow % 60
    
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
    
    func enableTheseButtons(runButtonEnabled: Bool = false, pauseButtonEnabled: Bool = false, stopButtonEnabled: Bool = false, nextButtonEnabled: Bool = false, goBackButtonEnabled: Bool = false) {
        runButton.enabled = runButtonEnabled
        pauseButton.enabled = pauseButtonEnabled
        stopButton.enabled = stopButtonEnabled
        
        nextButton.hidden = !nextButtonEnabled
        goBackButton.hidden = !goBackButtonEnabled
        
        doneButton.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        
        changeStateTo(TIMER_NOT_SET)
        
        // Переходим к следующему таймеру во время загрузки
        timersManager.moveToNextTimer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startFlowRightNow = false
        
        // Запрещаем телефону лочиться, когда открыто окно с потоком
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        if currentTimer {
            changeStateTo(TIMER_SET_BUT_NOT_STARTED)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        
        // Разрешаем телефону лочиться, когда переходим на другое окно
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        // Готовимся к возвращению на экран со списком таймеров
        if sender as NSObject == quitButton {
            // Если возвращаемся к таймерам из окна Потока, то нужно отменить все оповещения, так как поток при этом останавливается
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            // А заодно и таймер обнуляем на всякий случай
            currentTimer = nil
        }
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder!) {
        super.encodeRestorableStateWithCoder(coder)
        
        coder.encodeInt64(Int64(timerState!), forKey: "timerState")
        
        if timerState == RUNNING || timerState == PAUSED {
            coder.encodeBool(isRunningOvertime, forKey: "isRunningOvertime")
            coder.encodeInt64(Int64(firstLaunchMoment.timeIntervalSince1970), forKey: "firstLaunchMoment")
            if lastLaunchMoment {
                coder.encodeInt64(Int64(lastLaunchMoment.timeIntervalSince1970), forKey: "lastLaunchMoment")
            }
            else {
                coder.encodeInt64(0, forKey: "lastLaunchMoment")
            }
            coder.encodeInt64(Int64(secondsPassed), forKey: "secondsPassed")
        }
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder!) {
        super.decodeRestorableStateWithCoder(coder)
        
        if currentTimer {
            let restoredState = Int(coder.decodeIntForKey("timerState"))
            
            if restoredState == RUNNING || restoredState == PAUSED {
                timerState = restoredState
                isRunningOvertime = coder.decodeBoolForKey("isRunningOvertime")
                firstLaunchMoment = NSDate(timeIntervalSince1970: NSTimeInterval(coder.decodeInt64ForKey("firstLaunchMoment")))
                
                let intervalFoLastLaunchMoment = NSTimeInterval(coder.decodeInt64ForKey("lastLaunchMoment"))
                if intervalFoLastLaunchMoment > 0 {
                    lastLaunchMoment = NSDate(timeIntervalSince1970: intervalFoLastLaunchMoment)
                }
                else {
                    lastLaunchMoment = nil
                }
                
                secondsPassed = NSTimeInterval(coder.decodeInt64ForKey("secondsPassed"))
                
                // Восстанавливаем интерфейс
                txtTime.enabled = true
                txtTime.hidden = false
                showHideTimeButton.hidden = false
                timerControls.hidden = false
                doneButton.hidden = true
                
                // Восстанавливаем инфу о таймере
                totalSecondsToGo = NSTimeInterval(currentTimer.seconds)
                timerIsContinuous = currentTimer.isContinuous
                timerName = currentTimer.name
                txtName.text = currentTimer.name
                
                updateTimeLabel(Int(abs(totalSecondsToGo - secondsPassed)))
                
                if restoredState == RUNNING {
                    enableTheseButtons(pauseButtonEnabled: true, stopButtonEnabled: true)
                    
                    // Начинаем тикать
                    refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
                }
                else if restoredState == PAUSED {
                    enableTheseButtons(runButtonEnabled: true, stopButtonEnabled: true)
                }
            }
            else if restoredState != FINISHED && restoredState != TIMER_SET_BUT_NOT_STARTED {
                performSegueWithIdentifier("unwindToTimers", sender: nil)
            }
        }
        else {
            performSegueWithIdentifier("unwindToTimers", sender: nil)
        }
    }

}
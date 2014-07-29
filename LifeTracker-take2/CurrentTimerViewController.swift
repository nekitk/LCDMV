import UIKit
import AVFoundation

class CurrentTimerViewController: UIViewController {
    
    /*
            ТЕКСТОВЫЕ ПОЛЯ
    */
    
    @IBOutlet var txtName: UILabel!
    @IBOutlet var txtTime: UILabel!
    @IBOutlet var txtRestorationWarning: UILabel!
    
    
    
    /*
            КНОПКИ
    */
    
    @IBOutlet var timerControls: UIView!
    @IBOutlet var runButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var allTimersCompleteButton: UIButton!
    
    @IBOutlet var goBackBarButton: UIBarButtonItem!
    
    @IBOutlet var showHideTimeButton: UIButton!
    
    
    
    /*
            ЦВЕТА ФОНА
    */
    
    let bgRunningColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
    let bgPausedColor = UIColor.whiteColor()
    let bgFinishedColor = UIColor(red: 228/255, green: 243/255, blue: 248/255, alpha: 1)
    
    
    
    /*
            ЗВУКИ
    */
    
    var finishSoundPlayer: AVAudioPlayer!
    let finishSoundName = "tone.wav"
    let finishSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tone", ofType: "wav"))
    
    var startSoundPlayer: AVAudioPlayer!
    let startSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gong", ofType: "wav"))
    
    
    // Таймер обновления лэйбла с бегущим временем
    var refreshTimer: NSTimer!
    
    
    
    /*
            ПАРАМЕТРЫ ТЕКУЩЕГО ТАЙМЕРА
    */
    
    var timerName: String!
    var totalSecondsToGo: NSTimeInterval!
    var secondsPassed: NSTimeInterval = 0
    
    // Better not to use optionals with Bools
    // "if optionalBool" checks if optional is not nil, not the value of Bool itself
    var timerIsContinuous: Bool = false
    var isRunningOvertime: Bool = false
    
    var firstLaunchMoment: NSDate!
    var lastLaunchMoment: NSDate!
    
    // Состояния таймера
    var timerState: Int?
    let TIMER_SET_BUT_NOT_STARTED = 1
    let RUNNING = 2
    let PAUSED = 3
    let FINISHED = 4
    
    
    
    /*
            КЛИКИ ПО КНОПКАМ
    */
    
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
    
    
    
    /*
            СМЕНА СОСТОЯНИЙ
    */
    
    func changeStateTo(newState: Int) {
        
        // Check FROM-STATE transitions
        if timerState {
            
            switch timerState! {
            
            // Действия, совершаемые на выходе ИЗ ИДУЩЕГО состояния
            case RUNNING:
                
                refreshTimer.invalidate()
                
                let secondsPassedSinceLastLaunch = NSDate().timeIntervalSinceDate(lastLaunchMoment)
                secondsPassed = secondsPassed + secondsPassedSinceLastLaunch
                
                lastLaunchMoment = nil
                
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                
                
            default:
                break
            }
        }
        
        // Check TO-STATE transitions
        switch newState {
        
        case TIMER_SET_BUT_NOT_STARTED:
            
            // Копируем все данные таймера.
            // В таком случае нам не страшно удаление или изменение задачи.
            totalSecondsToGo = NSTimeInterval(currentTimer.seconds)
            timerIsContinuous = currentTimer.isContinuous
            timerName = currentTimer.name

            
        case RUNNING:
            
            // Если 0 секунд и не бесконечный, то это не таймер, а туду, и звук играть не надо. Пока так.
            if timerIsContinuous || totalSecondsToGo != 0 {
                startSoundPlayer.play()
            }
            
            // Сохраняем момент очередного запуска таймера
            // А если это первый запуск, то сохраняем и момент самого первого запуска
            lastLaunchMoment = NSDate()
            if !firstLaunchMoment {
                firstLaunchMoment = lastLaunchMoment
            }
            
            runRefreshTimer()
            
            scheduleNotifications()

            
        case PAUSED:
            
            // Интерфейс сам обновится, всякая логика срабатывает в момент выхода из запущенного состояния, так что тут делать особого и нечего
            break

            
        case FINISHED:

            secondsPassed = floor(secondsPassed)
            
            // Если это бесконечный таймер, то в завершённое состояние он переходит только по велению пользователя. А значит звук нужно играть всегда в таких случаях.
            if timerIsContinuous {
                finishSoundPlayer.play()
            }
            // Если это обычный таймер, который закончился вовремя или раньше положенного времени, то тоже играем звук.
            else if secondsPassed <= totalSecondsToGo {
                finishSoundPlayer.play()
            }
            // А вот если это обычный таймер, который закончился, пока телефон был залочен, то пользователю уже пришло оповещение со звуком. Тогда играть звук ещё раз не надо.
            // А надо сохранить в качестве прошедшего времени изначально заданное время таймера.
            else {
                secondsPassed = totalSecondsToGo
            }
            
            timersManager.markTimerAsCompleted(currentTimer, secondsPassed: Int(secondsPassed), startMoment: firstLaunchMoment)
            
            
        default:
            break
        }
        
        prepareInterfaceForState(newState)
        
        timerState = newState
        
    }
    
    
    
    /*
            ОБНОВЛЕНИЕ ИНТЕРФЕЙСА
    */
    
    // Подготовка интерфейса к определённому состоянию таймера
    func prepareInterfaceForState(state: Int) {
        switch state {
            
        case TIMER_SET_BUT_NOT_STARTED:
            
            enableTheseButtons(runButtonEnabled: true, goBackButtonEnabled: true)
            txtName.text = timerName
            updateTimeLabel(Int(totalSecondsToGo))
            
            if currentTimer.isToDo() {
                showHideTimeButton.hidden = true
                timerControls.hidden = true
                
                doneButton.hidden = false
            }
            else {
                showHideTimeButton.hidden = false
                timerControls.hidden = false
                
                doneButton.hidden = true
            }
            
            
        case RUNNING:
            
            enableTheseButtons(pauseButtonEnabled: true, stopButtonEnabled: true)
            view.backgroundColor = bgRunningColor
            
            
        case PAUSED:
            
            enableTheseButtons(runButtonEnabled: true, stopButtonEnabled: true)
            view.backgroundColor = bgPausedColor
            
            
        case FINISHED:
            
            // Если это был таймер, то показываем итог
            if !currentTimer.isToDo() {
                updateTimeLabel(Int(secondsPassed))
                txtTime.hidden = false
                showHideTimeButton.hidden = true
            }
            
            // Прячем управление таймером
            timerControls.hidden = true
            
            view.backgroundColor = bgFinishedColor
            
            // Показываем кнопку "Следующий", если он наличествует
            if timersManager.hasNextUncompleted() {
                enableTheseButtons(nextButtonEnabled: true, goBackButtonEnabled: true)
            }
            else {
                allTimersCompleteButton.hidden = false
                enableTheseButtons(goBackButtonEnabled: true)
            }
            
            
        default:
            break
        }
    }
    
    
    // Запускаем таймер обновления времени
    func runRefreshTimer() {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    
    // Активируем кнопки
    func enableTheseButtons(runButtonEnabled: Bool = false, pauseButtonEnabled: Bool = false, stopButtonEnabled: Bool = false, nextButtonEnabled: Bool = false, goBackButtonEnabled: Bool = false) {
        runButton.enabled = runButtonEnabled
        pauseButton.enabled = pauseButtonEnabled
        stopButton.enabled = stopButtonEnabled
        
        nextButton.hidden = !nextButtonEnabled
        goBackBarButton.enabled = goBackButtonEnabled
        
        doneButton.hidden = true
    }
    
    
    // Высчитываем оставшееся время
    func updateTime() {
        var secondsPassedSinceLastLaunch = NSTimeInterval(0)
        
        if lastLaunchMoment {
            secondsPassedSinceLastLaunch = NSDate().timeIntervalSinceDate(lastLaunchMoment)
        }
        
        let secondsLeft = Int(ceil((totalSecondsToGo - secondsPassed) - secondsPassedSinceLastLaunch))
        
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
            }
        }
    }
    
    
    // Форматируем время в 00:00
    func updateTimeLabel(timeToShow: Int) {
        let minutesToShow = timeToShow / 60
        let secondsToShow = timeToShow % 60
        
        // Добавляем нолики к секундам
        var secondsString: String!
        if secondsToShow < 10 {
            secondsString = "0\(secondsToShow)"
        }
        else {
            secondsString = String(secondsToShow)
        }
        
        txtTime.text = "\(minutesToShow):\(secondsString)"
    }
    
    
    
    /*
            ОПОВЕЩЕНИЯ
    */
    
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
    
    
    
    /*
            ПОЯВЛЕНИЕ ЭКРАНА И ПЕРЕХОДЫ
    */
    
    var waitForDocumentLoadTimer: NSTimer!
    
    // Загрузка экрана
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize sound players
        finishSoundPlayer = AVAudioPlayer(contentsOfURL: finishSoundURL, error: nil)
        startSoundPlayer = AVAudioPlayer(contentsOfURL: startSoundURL, error: nil)
        
        waitForDocumentLoadTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "timersLoaded", userInfo: nil, repeats: true)
    }
    
    var viewFullyLoaded = false
    
    func timersLoaded() {
        if timersManager.isReady() {
            waitForDocumentLoadTimer.invalidate()
            
            // Переходим к следующему таймеру во время загрузки
            timersManager.moveToNextTimer()
            
            if currentTimer {
                changeStateTo(TIMER_SET_BUT_NOT_STARTED)
                
                // Если тудушка, то моментом начала считаем время её появления на экране
                if currentTimer.isToDo() {
                    firstLaunchMoment = NSDate()
                }
                
                // Запрещаем телефону лочиться, когда открыто окно с потоком
                UIApplication.sharedApplication().idleTimerDisabled = true
                
                // Проставляем флаг о том, что окно полностью загружено для того, чтобы после этого применить восстановление
                viewFullyLoaded = true
            }
            else {
                // Если по каким-то причинам текущего таймера нет, то проваливаем
                performSegueWithIdentifier("unwindToTimersFromFlow", sender: nil)
            }
        }
    }
    
    
    // Возврат к списку таймеров
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        
        // Разрешаем телефону лочиться, когда переходим на другое окно
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    
    
    /*
            СОХРАНЕНИЕ И ВОССТАНОВЛЕНИЕ СОСТОЯНИЯ ПРИЛОЖЕНИЯ
    */
    
    // Сохраняем состояние
    override func encodeRestorableStateWithCoder(coder: NSCoder!) {
        super.encodeRestorableStateWithCoder(coder)
        
        coder.encodeInt64(Int64(timerState!), forKey: "timerState")
        coder.encodeInt64(Int64(timersManager.currentTimerIndex), forKey: "currentTimerIndex")
        
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
    
    // Таймер для ожидания загрузки таймеров
    var restorationWaitingTimer: NSTimer!
    
    // Переменные для хранения промежуточных восстановлённых параметров
    var restoredIndex: Int!
    var restoredState: Int!
    
    // Восстанавливаем состояние
    override func decodeRestorableStateWithCoder(coder: NSCoder!) {
        super.decodeRestorableStateWithCoder(coder)
        
        // Восстанавливаем параметры таймера прямо здесь, а то coder уничтожается, если пытаться повременить
        restoredIndex = Int(coder.decodeInt64ForKey("currentTimerIndex"))
        restoredState = Int(coder.decodeInt64ForKey("timerState"))
        isRunningOvertime = coder.decodeBoolForKey("isRunningOvertime")
        firstLaunchMoment = NSDate(timeIntervalSince1970: NSTimeInterval(coder.decodeInt64ForKey("firstLaunchMoment")))

        let intervalForLastLaunchMoment = NSTimeInterval(coder.decodeInt64ForKey("lastLaunchMoment"))
        if intervalForLastLaunchMoment > 0 {
            lastLaunchMoment = NSDate(timeIntervalSince1970: intervalForLastLaunchMoment)
        }
        else {
            lastLaunchMoment = nil
        }
        
        secondsPassed = NSTimeInterval(coder.decodeInt64ForKey("secondsPassed"))
        
        // Ждём, пока загрузятся таймеры, чтобы завершить восстановление
        restorationWaitingTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "finishRestoration", userInfo: nil, repeats: true)
    }
    
    func finishRestoration() {
        // Если таймеры загрузились и окно полностью загрузилось, то восстанавливаем состояние
        if timersManager.isReady() && viewFullyLoaded {
            
            restorationWaitingTimer.invalidate()
            
            if currentTimer {
                // Восстанавливаем только в том случае, если текущий таймер и сохранённый -- это один и тот же.
                if restoredIndex == timersManager.currentTimerIndex {
                    
                    // И только если таймер идёт или на паузе (в остальных случаях нет смысла восстанавливать)
                    if restoredState == RUNNING || restoredState == PAUSED {
                        
                        // Восстанавливаем состояние таймера в обход метода changeStateTo, так как это не смена состояния, а его восстановление
                        timerState = restoredState
                        
                        // Восстанавливаем интерфейс
                        prepareInterfaceForState(TIMER_SET_BUT_NOT_STARTED)
                        prepareInterfaceForState(restoredState)
                        
                        if restoredState == RUNNING {
                            runRefreshTimer()
                        }
                        else {
                            updateTime()
                        }
                    }
                }
                else {
                    // Показываем предупреждение, что восстановленный таймер не совпадает с текущим. Может быть, удастся понять, из-за чего это происходит
                    txtRestorationWarning.hidden = false
                }
            }
            else {
                // Если текущий таймер не проставлен, то проваливаем. Почему-то при восстановлении переход не совершается, если его вызывать в методе viewDidLoad
                performSegueWithIdentifier("unwindToTimersFromFlow", sender: nil)
            }
        }
    }

}
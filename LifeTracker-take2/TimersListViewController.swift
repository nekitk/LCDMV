import UIKit

@objc(TimersListViewController) class TimersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var timersTable : UITableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timersTable.reloadData()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let timersCount = timersManager.getTimersCount()
        
        // Если есть незавершённые таймеры, то показываем кнопку "Начать"
        if timersManager.hasNextUncompleted() {
            return timersCount + 1
        }
        else {
            return timersCount
        }
    }
    
    // ОТОБРАЖЕНИЕ КЛЕТОК
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell!
        
        // КЛЕТКА-КНОПКА СТАРТ
        if indexPath.row == timersManager.getTimersCount() {
            cell = timersTable.dequeueReusableCellWithIdentifier("StartFlowPrototypeCell", forIndexPath: indexPath) as UITableViewCell
        }
        // КЛЕТКИ ТАЙМЕРОВ
        else {
            let timer = timersManager.getTimerByIndex(indexPath.row)
            
            // В зависимости от того, выполнена задача или ещё нет, по-разному оформляем её клетку
            let cellIdentifier: String = timer.completed ? "CompletedTimerPrototypeCell" : "TimerPrototypeCell"
            cell = timersTable.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel.text = timer.name
            
            if timer.seconds != 0 || timer.isContinuous {
                let minutes = timer.seconds / 60
                let minutesString = minutes == 0 ? "" : "\(minutes) min"
                
                let secondsWithoutMinutes = timer.seconds % 60
                var secondsString = ""
                
                // Показываем секунды только если:
                // 1. Таймер не завершён (для завершённых таймеров -- только минуты)
                // 2. Количество секунд не равно 0
                if !timer.completed && secondsWithoutMinutes != 0 {
                    secondsString = " \(secondsWithoutMinutes) sec"
                }
                
                cell.detailTextLabel.text = "\(minutesString)\(secondsString)"
                
                if timer.isContinuous && !timer.completed {
                    cell.detailTextLabel.text = cell.detailTextLabel.text + " ..."
                }
            }
            else {
                cell.detailTextLabel.text = "todo"
            }
        }
        
        return cell
    }
    
    // УДАЛЕНИЕ ТАЙМЕРА
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let uncompletedTimersBefore = timersManager.getUncompletedTimersCount()
            
            timersManager.removeTimer(indexPath.row)
            
            let uncompletedTimersAfter = timersManager.getUncompletedTimersCount()
            
            // Если удалили последний незавершённый таймер (раньше были, а теперь 0), то сносим обе клетки
            if uncompletedTimersAfter == 0 && uncompletedTimersBefore != 0 {
                timersTable.deleteRowsAtIndexPaths([indexPath, NSIndexPath(forRow: indexPath.row + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            else {
                timersTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }
            
        }
    }
    
    // СТИЛИ РЕДАКТИРОВАНИЯ
    
    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        if indexPath.row >= timersManager.getTimersCount() {
            // Запрещаем редактирование для дополнительных функциональных клеток (старт и удалить все)
            return UITableViewCellEditingStyle.None
        }
        else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    // Back transition from adding timer screen
    @IBAction func unwindToTimers(segue: UIStoryboardSegue) {
        if segue.sourceViewController is CurrentTimerViewController {
            timersTable.reloadData()
        }
        else if segue.sourceViewController is AddTimerViewController {
            
            // Если таймер был добавлен...
            if (segue.sourceViewController as AddTimerViewController).timerWasAdded {
                let timersCount = timersManager.getTimersCount()

                let newRowIndex = NSIndexPath(forRow: timersCount - 1, inSection: 0)
                let startFlowRowIndex = NSIndexPath(forRow: timersCount, inSection: 0)
                
                // Если это первый незавершённый таймер, то вместе с ним должна появиться кнопка "Старт"
                if timersManager.getUncompletedTimersCount() == 1 {
                    timersTable.insertRowsAtIndexPaths([newRowIndex, startFlowRowIndex], withRowAnimation: UITableViewRowAnimation.None)
                }
                else {
                    timersTable.insertRowsAtIndexPaths([newRowIndex], withRowAnimation: UITableViewRowAnimation.Right)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if startFlowRightNow {
            performSegueWithIdentifier("pushToFlowScreen", sender: nil)
        }
    }
    
}

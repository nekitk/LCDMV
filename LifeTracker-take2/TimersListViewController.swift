import UIKit

class TimersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var timersTable : UITableView!
    
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
            
            // Тудушка
            if timer.isToDo() && !timer.completed {
                cell.detailTextLabel.text = "todo"
            }
            // Завершённый таймер
            else if timer.completed {
                let minutesString = timer.isToDo() ? "todo" : "\(timer.seconds / 60) min"
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = .ShortStyle
                dateFormatter.dateStyle = .NoStyle
                
                let startTimeString = dateFormatter.stringFromDate(timer.startMoment)
                let endTimeString = dateFormatter.stringFromDate(timer.endMoment)
                
                cell.detailTextLabel.text = "\(startTimeString) - \(endTimeString) (\(minutesString))"
            }
            // Незавершённый таймер
            else {
                
                // И минуты, и секунды показываем, только если их не 0
                let minutes = timer.seconds / 60
                let minutesString = (minutes == 0) ? "" : "\(minutes) min"
                
                let secondsWithoutMinutes = timer.seconds % 60
                let secondsString = (secondsWithoutMinutes == 0) ? "" : " \(secondsWithoutMinutes) sec"
                
                cell.detailTextLabel.text = "\(minutesString)\(secondsString)"
                
                if timer.isContinuous {
                    cell.detailTextLabel.text = cell.detailTextLabel.text + " ..."
                }
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

                let newRowIndexPath = NSIndexPath(forRow: timersCount - 1, inSection: 0)
                let startFlowRowIndexPath = NSIndexPath(forRow: timersCount, inSection: 0)
                
                // Если это первый незавершённый таймер, то вместе с ним должна появиться кнопка "Старт"
                if timersManager.getUncompletedTimersCount() == 1 {
                    timersTable.insertRowsAtIndexPaths([newRowIndexPath, startFlowRowIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                }
                else {
                    timersTable.insertRowsAtIndexPaths([newRowIndexPath], withRowAnimation: UITableViewRowAnimation.Right)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if startFlowRightNow {
            performSegueWithIdentifier("pushToFlowScreen", sender: nil)
            startFlowRightNow = false
        }
        else {
            if timersManager.getTimersCount() > 0 {
                // Пролистываем в самый низ
                timersTable.scrollToRowAtIndexPath(NSIndexPath(forRow: timersManager.getTimersCount() - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
    }
    
}

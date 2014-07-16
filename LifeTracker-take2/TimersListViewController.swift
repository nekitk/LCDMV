import UIKit

@objc(TimersListViewController) class TimersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var timersTable : UITableView
    
    override func viewDidLoad() {
        timersTable.reloadData()
    }
    
    // UITableViewDataSource implementation
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let timersCount = timersManager.getTimersCount()
        if timersCount == 0 {
            return 0
        }
        else {
            return timersManager.getTimersCount() + 1
        }
    }
    
    // ОТОБРАЖЕНИЕ КЛЕТОК
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell!
        
        // ФУНКЦИОНАЛЬНЫЕ КЛЕТКИ
        if indexPath.row == timersManager.getTimersCount() {

            if timersManager.hasNextUncompleted() {
                // КЛЕТКА-КНОПКА СТАРТ, если есть незавершённые таймеры,
                cell = timersTable.dequeueReusableCellWithIdentifier("StartFlowPrototypeCell", forIndexPath: indexPath) as UITableViewCell
            }
            else {
                // КЛЕТКА-КНОПКА УДАЛИТЬ ВСЕ, если все таймеры завершены
                cell = timersTable.dequeueReusableCellWithIdentifier("DeleteAllCompletedPrototypeCell", forIndexPath: indexPath) as UITableViewCell
            }
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
                let secondsString = secondsWithoutMinutes == 0 ? "" : " \(secondsWithoutMinutes) sec"
                
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
            timersManager.removeTimer(indexPath.row)
            
            // Если остались ещё другие таймеры, то сносим только клетку с удаляемым таймером
            if timersManager.getTimersCount() != 0 {
                timersTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            }
            // Если таймеров не осталось, то сносим обе оставшиеся клетки
            else {
                timersTable.deleteRowsAtIndexPaths([indexPath, NSIndexPath(forRow: indexPath.row + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
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
                let functionalRowIndex = NSIndexPath(forRow: timersCount, inSection: 0)
                
                // Если это самый первый таймер, то кнопка должна появиться вместе с ним
                if timersCount == 1 {
                    timersTable.insertRowsAtIndexPaths([newRowIndex, functionalRowIndex], withRowAnimation: UITableViewRowAnimation.None)
                }
                // Если это уже не первый таймер, то добавляем его строчку, а последнюю обновляем на тот случай, если она должна поменяться с "Удалить все" на "Старт"
                else {
                    timersTable.insertRowsAtIndexPaths([newRowIndex], withRowAnimation: UITableViewRowAnimation.Right)
                    timersTable.reloadRowsAtIndexPaths([functionalRowIndex], withRowAnimation: UITableViewRowAnimation.None)
                }
                
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if startFlowRightNow {
            performSegueWithIdentifier("pushToFlowScreen", sender: nil)
        }
    }
    
    // Удалить все завершённые таймеры
    @IBAction func deleteAllCompletedTimers(sender: AnyObject) {
        timersManager.deleteAllCompleted()
        timersTable.reloadData()
    }
    
}

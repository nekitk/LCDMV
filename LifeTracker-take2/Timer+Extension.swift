// MARK: Printable

extension Timer: Printable {
    
    // Расширение не может добавлять никакие параметры, только методы и параметры с геттерами/сеттерами
    
    override var description: String {
        return "Timer \(name)"
    }
    
    // @objc тут нужно для того, чтобы не было ошибки компиляции
    // Если переменная находится прямо в классе Timer, то никаких проблем нет
    // Ошибка компиляции возникает только в том случае, когда переменная вынесена в расширение
    @objc var isToDo: Bool {
        if seconds == 0 && !isContinuous {
            return true
        }
        else {
            return false
            }
    }
}
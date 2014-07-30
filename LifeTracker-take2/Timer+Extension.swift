extension Timer: Printable {
    
    // Расширение не может добавлять никакие параметры, только методы и параметры с геттерами/сеттерами
    
    override var description: String {
        return "Timer \(name)"
    }
    
    func isToDo() -> Bool {
        if seconds == 0 && !isContinuous {
            return true
        }
        else {
            return false
        }
    }
}
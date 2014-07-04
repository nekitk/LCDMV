import UIKit

class Timer: NSObject {
    var name: String
    var seconds: Int
    var isContinuos: Bool
    
    init(name: String, seconds: Int, isContinuos: Bool) {
        self.name = name
        self.seconds = seconds
        self.isContinuos = isContinuos
    }
}
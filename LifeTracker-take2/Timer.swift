import UIKit

class Timer: NSObject {
    var name: String
    var seconds: Int
    var isContinuous: Bool
    
    init(name: String, seconds: Int, isContinuous: Bool) {
        self.name = name
        self.seconds = seconds
        self.isContinuous = isContinuous
    }
}
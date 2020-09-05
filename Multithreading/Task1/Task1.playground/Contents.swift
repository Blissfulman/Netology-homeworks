import Foundation

/// Хлеб
public struct Bread {
    
    public enum BreadType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let breadType: BreadType
    
    public static func make() -> Bread {
        guard let breadType = Bread.BreadType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Bread(breadType: breadType)
    }
    
    public func bake() {
        let bakeTime = breadType.rawValue
        sleep(UInt32(bakeTime))
    }
}

/// Хранилище хлеба
class BreadStorage {
    
    private var breadStack = [Bread]()
    
    private let condition = NSCondition()
    
    public var count: Int {
        return breadStack.count
    }
    
    public func push(_ bread: Bread) {
        condition.lock()
        breadStack.append(bread)
        print("Подготовлена новая булка. Всего в хранилище: \(self.breadStack.count)")
        condition.signal()
        condition.unlock()
    }
    
    public func pop() -> Bread? {
        condition.lock()
        while breadStack.isEmpty {
//            print("Жду появления хлеба")
            condition.wait()
        }
        let bread = !breadStack.isEmpty ? breadStack.removeLast() : nil
        print("Одна булка взята. Осталось в хранилище: \(self.breadStack.count)")
        condition.unlock()
        return bread
    }
}

/// Порождающий поток, создающий хлеб
class GeneratingThread: Thread {
    
    let breadStorage: BreadStorage
    
    init(breadStorage: BreadStorage) {
        self.breadStorage = breadStorage
        super.init()
    }
    
    override func main() {
        let timer = Timer(timeInterval: 2, repeats: true) { _ in
            self.breadStorage.push(Bread.make())
        }
        
        RunLoop.current.add(timer, forMode: .default)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
    }
}

/// Рабочий поток, запекающий хлеб
class WorkThread: Thread {
    
    let breadStorage: BreadStorage
    
    init(breadStorage: BreadStorage) {
        self.breadStorage = breadStorage
        super.init()
    }
    
    override func main() {
        var countBakedBread = 0
        
        while generatingThread.isExecuting || self.breadStorage.count != 0 {
            
            // Запекание подготовленного хлеба из хранилища
            guard let breadForBake = self.breadStorage.pop() else { return }
            breadForBake.bake()
            countBakedBread += 1
            print("Хлеб испечён! Всего испеклось: \(countBakedBread)")
        }
        
        // Т.к. порождающий поток уже финишировал и запекать больше нечего, получается, что испечён весь хлеб
        print("Весь хлеб испечён!!!")
    }
}

let breadStorage = BreadStorage()
let generatingThread = GeneratingThread(breadStorage: breadStorage)
let workThread = WorkThread(breadStorage: breadStorage)
generatingThread.start()
workThread.start()


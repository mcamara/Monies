import RealmSwift

class Account: Object {
    dynamic var accountNumber = ""
    dynamic var balance = ""
    dynamic var availableBalance = ""
    dynamic var title = ""
    dynamic var updatedAt = ""
    
    func updatedAtDate() -> NSDate {
        let interval = (updatedAt as NSString).doubleValue
        return NSDate(timeIntervalSince1970: interval)
    }
}
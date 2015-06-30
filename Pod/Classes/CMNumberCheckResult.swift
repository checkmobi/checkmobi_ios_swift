import Foundation

public struct CMValidationMethod {
    var available: Bool
    var localNumber: Bool?
    var minRate: Float?
    var maxRate: Float?
    var estimationCost: Float?
    
    public init?(_ dict: [String:AnyObject]?) {
        if let dict = dict {
            if let available = dict["available"] as? Bool {
                self.available = available
                self.localNumber = dict["local_number"] as? Bool
                self.minRate = dict["min_rate"] as? Float
                self.maxRate = dict["max_rate"] as? Float
                self.estimationCost = dict["estimation_cost"] as? Float
                return
            }
        }
        return nil
    }
}

public struct CMNumberCheckResult {
    public var countryCode: Int
    public var countryIsoCode: String
    public var carrier: String
    public var isMobile: Bool
    public var e164Format: String
    public var formatting: String
    public var validationMethods: [CMValidationType:CMValidationMethod]?
    
    public init?(_ dict: [String:AnyObject]?) {
        if let dict = dict {
            if let e164Format = dict["e164_format"] as? String {
                self.e164Format = e164Format
                self.countryCode = dict["country_code"] as! Int
                self.countryIsoCode = dict["country_iso_code"] as! String
                self.carrier = dict["carrier"] as! String
                self.isMobile = dict["is_mobile"] as! Bool
                self.formatting = dict["formatting"] as! String
                self.validationMethods = [CMValidationType:CMValidationMethod]()
                if let validationMethods = dict["validation_methods"] as? [String:[String:AnyObject]] {
                    for (vType, vDict) in validationMethods {
                        if let validationType = CMValidationType(rawValue: vType) {
                            self.validationMethods![validationType] = CMValidationMethod(vDict)!
                        }
                    }
                }
                return
            }
        }
        return nil
    }
}
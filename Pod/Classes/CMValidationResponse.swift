import Foundation

public struct CMValidationResponse {
    public var id: String
    public var type: CMValidationType
    public var pinHash: String?
    public var dialingNumber: String?
    public var validationInfo: CMNumberCheckResult
    
    public init?(_ dict: [String:AnyObject]?) {
        if let id = dict?["id"] as? String {
            self.id = id
            self.type = CMValidationType(rawValue: dict?["type"] as! String)!
            self.pinHash = dict?["pin_hash"] as? String
            self.dialingNumber = dict?["dialing_number"] as? String
            self.validationInfo = CMNumberCheckResult(dict?["validation_info"] as? [String:AnyObject])!
            return
        }
        return nil
    }
}
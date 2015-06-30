import Foundation

public struct CMVerificationStatus {
    public var number: String
    public var validated: Bool
    public var validationDate: Int?
    public var chargedAmount: Float
    
    public init?(_ dict: [String:AnyObject]?) {
        if let number = dict?["number"] as? String {
            self.number = number
            self.validated = dict?["validated"] as! Bool
            self.validationDate = dict?["validation_date"] as? Int
            self.chargedAmount = dict?["charged_amount"] as! Float
            return
        }
        return nil
    }
}
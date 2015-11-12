import Foundation

public enum CMValidationType: String {
    case SMS = "sms"
    case CLI = "cli"
    case IVR = "ivr"
    case ReverseCLI = "reverse_cli"
}

public struct CMCountry {
    var iso2: String
    var name: String
    var flags: [String:String]
    public init?(_ dict: [String:String]?) {
        if let iso2 = dict?["iso2"] {
            if let name = dict?["name"] {
                self.iso2 = iso2
                self.name = name
                flags = [String:String]()
                for flag_size in ["32", "128"] {
                    if let flag = dict?["flag_\(flag_size)"] {
                        flags[flag_size] = flag
                    }
                }
                return
            }
        }
        return nil
    }
}

public enum CMErrorCode: Int {
    case InvalidApiKey = 1
    case InvalidPhoneNumber
    case InvalidRequestId
    case InvalidValidationType
    case InsufficientFounds
    case InsufficientCliValidations
    case InvalidRequestPayload
    case ValidationMehodNotAvailableInRegion
    case InvalidNotificationURL
}

public class CheckMobiService {
    public static let sharedInstance = CheckMobiService()
    
    struct Constants {
        static let defaultBaseUrl = "https://api.checkmobi.com/v1/"
        static let requestValidationUrl = "validation/request"
        static let validationStatusUrl = "validation/status"
        static let validationPinVerifyUrl = "validation/verify"
        static let validationCheckNumberUrl = "checknumber"
        static let requestCountriesUrl = "countries"
    }
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    
    enum HTTPStatusCode: UInt {
        case SuccessWithContent = 200
        case SuccessWithNoContent = 204
        case BadRequest = 400
        case Unauthorized = 401
        case NotFound = 404
        case InternalServerError = 500
    }
    
    let AuthorizationHeader = "Authorization"
    
    public var baseUrl: String
    public var secretKey: String = ""
    public var ivrLanguage: String = ""
    public var smsLanguage: String = ""
    public var language: String {
        get {
            return smsLanguage ?? ivrLanguage
        }
        set {
            ivrLanguage = newValue
            smsLanguage = newValue
        }
    }
    public var notificationUrl: String?
    
    private init() {
        baseUrl = Constants.defaultBaseUrl
    }
    
    private func getUrl(resource: String) -> String {
        return (baseUrl ?? Constants.defaultBaseUrl) + resource
    }
    
    class private func encodeString(string: String) -> String {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
    }
    
    private func parseResponseBody(data: NSData?) -> AnyObject? {
        guard let data = data else { return nil }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch _ {
            return nil
        }
    }
    
    private func performRequest(url: String, method: HTTPMethod, params: [String:AnyObject]?, callback: ((AnyObject?, NSError?) -> ())?) {
        let jsonData: NSData?
        if let params = params {
            do {
                jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 0))
            } catch _ {
                jsonData = nil
            }
        } else {
            jsonData = nil
        }
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: getUrl(url))!,
            cachePolicy: .ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = [AuthorizationHeader: secretKey]
        if let jsonData = jsonData {
            urlRequest.HTTPBody = jsonData
        }
        let connection = CMAsyncHTTPConnection(urlRequest)
        connection.executeRequest(success: { (httpResponse: NSHTTPURLResponse?, body: NSData?) -> () in
                let bodyDict: AnyObject? = self.parseResponseBody(body)
                if let callback = callback {
                    var error: NSError?
                    if httpResponse?.statusCode >= 400 {
                        if let bodyDict = bodyDict as? [String:AnyObject] {
                            if let errorCode = bodyDict["code"] as? Int {
                                error = NSError(domain: "com.checkmobi", code: errorCode, userInfo: [NSLocalizedDescriptionKey: bodyDict["error"] ?? ""])
                            } else {
                                if let httpResponse = httpResponse {
                                    error = NSError(domain: "com.checkmobi", code: httpResponse.statusCode, userInfo: bodyDict)
                                } else {
                                    error = NSError(domain: "com.checkmobi", code: 0, userInfo: bodyDict)
                                }
                            }
                        }
                        if error == nil {
                            if let httpResponse = httpResponse {
                                error = NSError(domain: "com.checkmobi", code: httpResponse.statusCode, userInfo: nil)
                            } else {
                                error = NSError(domain: "com.checkmobi", code: 0, userInfo: nil)
                            }
                        }
                    }
                    callback(bodyDict, error)
                }
            },
            failure: { (httpResponse: NSHTTPURLResponse?, body: NSData?, error: NSError?) -> () in
                
                let bodyDict: AnyObject? = self.parseResponseBody(body)
                
                NSLog("Failed Response: \(httpResponse?.statusCode) body: \(bodyDict) error: \(error?.description)")
                
                if let callback = callback {
                    var error: NSError?
                    if httpResponse?.statusCode >= 400 {
                        if let bodyDict = bodyDict as? [String:AnyObject] {
                            if let errorCode = bodyDict["code"] as? Int {
                                error = NSError(domain: "com.checkmobi", code: errorCode, userInfo: [NSLocalizedDescriptionKey: bodyDict["error"] ?? ""])
                            } else {
                                if let httpResponse = httpResponse {
                                    error = NSError(domain: "com.checkmobi", code: httpResponse.statusCode, userInfo: bodyDict)
                                } else {
                                    error = NSError(domain: "com.checkmobi", code: 0, userInfo: bodyDict)
                                }
                            }
                        }
                        if error == nil {
                            if let httpResponse = httpResponse {
                                error = NSError(domain: "com.checkmobi", code: httpResponse.statusCode, userInfo: nil)
                            } else {
                                error = NSError(domain: "com.checkmobi", code: 0, userInfo: nil)
                            }
                        }
                    }
                    callback(bodyDict, error)
                }
        })
    }
    
    public func requestValidation(type type: CMValidationType, number e164_number: String, callback: (CMValidationResponse?, NSError?) -> ()) {
        var params = [String:String]()
        params["type"] = type.rawValue
        params["number"] = e164_number
        if let notificationUrl = notificationUrl {
            params["notification_callback"] = notificationUrl
        }
        
        switch type {
            case .IVR:
                params["language"] = ivrLanguage
            case .SMS:
                params["language"] = smsLanguage
            default:
                break
        }
        
        performRequest(Constants.requestValidationUrl, method: .POST, params: params) { (response: AnyObject?, error: NSError?) -> () in
            if error !== nil {
                callback(nil, error)
                return
            }
            if let result = CMValidationResponse(response as? [String:AnyObject]) {
                callback(result, nil)
                return
            }
            callback(nil, NSError(domain: "com.checkmobi", code: 0, userInfo: nil))
        }
    }
    
    public func checkValidationStatus(requestId requestId: String, callback: (CMVerificationStatus?, NSError?) -> ()) {
        let url = "\(Constants.validationStatusUrl)/\(requestId)"
        performRequest(url, method: .GET, params: nil) { (response: AnyObject?, error: NSError?) -> () in
            if error !== nil {
                callback(nil, error)
                return
            }
            if let result = CMVerificationStatus(response as? [String:AnyObject]) {
                callback(result, nil)
                return
            }
            callback(nil, NSError(domain: "com.checkmobi", code: 0, userInfo: nil))
        }
    }
    
    public func verifyPin(requestId requestId: String, pin: String, callback: (CMVerificationStatus?, NSError?) -> ()) {
        let params = ["id": requestId, "pin": pin]
        performRequest(Constants.validationPinVerifyUrl, method: .POST, params: params){ (response: AnyObject?, error: NSError?) -> () in
            if error !== nil {
                callback(nil, error)
                return
            }
            if let result = CMVerificationStatus(response as? [String:AnyObject]) {
                callback(result, nil)
                return
            }
            callback(nil, NSError(domain: "com.checkmobi", code: 0, userInfo: nil))
        }
    }
    
    public func checkNumberInfo(e164_number: String, callback: (CMNumberCheckResult?, NSError?) -> ()) {
        let params = ["number": e164_number]
        performRequest(Constants.validationCheckNumberUrl, method: .POST, params: params) { (response: AnyObject?, error: NSError?) -> () in
            if error !== nil {
                callback(nil, error)
                return
            }
            if let result = CMNumberCheckResult(response as? [String:AnyObject]) {
                callback(result, nil)
                return
            }
            callback(nil, NSError(domain: "com.checkmobi", code: 0, userInfo: nil))
        }
    }
    
    public func getCountryList(callback: ([CMCountry]?, NSError?) -> ()) {
        performRequest(Constants.requestCountriesUrl, method: .GET, params: nil) { (response: AnyObject?, error: NSError?) -> () in
            if error !== nil {
                callback(nil, error)
                return
            }
            if let countryList = response as? [[String:String]] {
                let countries: [CMCountry] = countryList.map { CMCountry($0)! }
                callback(countries, nil)
                return
            }
            callback(nil, NSError(domain: "com.checkmobi", code: 0, userInfo: nil))
        }
    }
}
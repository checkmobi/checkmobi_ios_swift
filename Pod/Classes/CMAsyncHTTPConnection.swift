import Foundation

public class CMAsyncHTTPConnection: NSObject, NSURLConnectionDataDelegate {
    typealias OnSuccess = (NSHTTPURLResponse?, NSData) -> ()
    typealias OnFailure = (NSHTTPURLResponse?, NSData?, NSError) -> ()
    
    var request: NSURLRequest
    var response: NSHTTPURLResponse?
    var data: NSMutableData?
    
    var onSuccess: OnSuccess?
    var onFailure: OnFailure?
    
    let ignoreInvalidCertificates = true
    
    init(_ request: NSURLRequest) {
        self.request = request
    }
    
    func executeRequest(success success: OnSuccess?, failure: OnFailure?) -> Bool {
        onSuccess = success
        onFailure = failure
        
        let connection = NSURLConnection(request: self.request, delegate: self)
        
        return connection != nil
    }
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.response = response as? NSHTTPURLResponse
        data = NSMutableData()
        data?.length = 0
    }
    public
    func connection(connection: NSURLConnection, didReceiveData bytes: NSData) {
        data?.appendData(bytes)
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if let onFailure = onFailure {
            onFailure(response, data, error)
        }
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        if let onSuccess = onSuccess {
            onSuccess(response, data!)
        }
    }
    
    public func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil
    }
    
    public func connection(connection: NSURLConnection,
        willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                let trust = challenge.protectionSpace.serverTrust
                var trustResult: SecTrustResultType = 0
                SecTrustEvaluate(trust!, &trustResult)
                if (Int(trustResult) == kSecTrustResultUnspecified ||
                    Int(trustResult) == kSecTrustResultProceed ||
                    !ignoreInvalidCertificates) {
                        // Trust certificate.
                        let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                        challenge.sender!.useCredential(credential, forAuthenticationChallenge: challenge)
                } else {
                    challenge.sender!.cancelAuthenticationChallenge(challenge)
                }
            } else {
                challenge.sender!.cancelAuthenticationChallenge(challenge)
            }
    }
    
}
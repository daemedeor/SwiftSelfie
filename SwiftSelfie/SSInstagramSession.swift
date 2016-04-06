//
//  SSInstagramSession.swift
//  SwiftSelfie
//
//  Created by Justin Wong on 11/14/15.
//  Copyright (c) 2015 TEST. All rights reserved.
//

import Foundation

class SSInstagramSession : NSObject {
    
    //Properties for getting data from instagram, and delegate variable for communicating back to presenter object
    let accessToken = "e0569d416a8e4845bf5eb2e5de16f901"
    let tag = "selfie"
    var nextURL = ""
    var delegate : SSSessionDelegate?
    
    //Return singleton of session object
    class var sharedInstance: SSInstagramSession {
        struct Static {
            static var instance: SSInstagramSession?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SSInstagramSession()
        }
        return Static.instance!
    }
    
    //Get next batch of data based on either next URL or initial url.
    func getImageURLs() {
        
        if( nextURL == "") {
            nextURL = "https://api.instagram.com/v1/tags/" + tag + "/media/recent/?client_id=" + accessToken
        }
        
        //Set up session values to acquire data
        let defaultConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let mySession = NSURLSession(configuration: defaultConfig)
        let NSurl : NSURL = NSURL(string: nextURL)!
        let request : NSURLRequest = NSURLRequest(URL: NSurl)
        let myDataTask = mySession.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            // Serialize data, update pagination value, and send data via delegate to presenter
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let paginationDict = json.objectForKey("pagination") as! NSDictionary
            self.nextURL = paginationDict.objectForKey("next_url") as! String
            self.delegate?.acquiredImageURLs( json.objectForKey("data") as! NSArray )
        })
        
        myDataTask.resume()
        mySession.finishTasksAndInvalidate()
    }
    
    func getImage ( url : NSString, index : Int ){
        
        //Set up session values to acquire data
        let defaultConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let mySession = NSURLSession(configuration: defaultConfig)
        let NSurl : NSURL = NSURL(string: url as String)!
        let request : NSURLRequest = NSURLRequest(URL: NSurl)
        let myDataTask = mySession.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            //Send data via delegate to presenter
            self.delegate?.acquiredImage( data!, index: index )
        })
        
        myDataTask.resume()
        mySession.finishTasksAndInvalidate()
    }
    
}

//
//  IGUserSDK.swift
//  ignidataSurveyPlugin
//
//  Created by Andre Muchagata on 10/08/2015.
//  Copyright (c) 2015 Andre Muchagata. All rights reserved.
//

import Foundation
import UIKit


public class IGSurveySDK:NSObject
{
    var apiPaths = NSMutableDictionary()
    var apiRoot = NSString()
    var params = NSDictionary()
    
    var mainView = IGMainViewController()
    var userData = IGUserData()
    
    
    let URLSURVEY = "http://surveys.ignidata.com/getMobileSurvey"
    //let URLSURVEY = "http://192.168.3.88:9000/getMobileSurvey"
    //let URLSURVEY = "http://www.google.com"
    override init()
    {
        super.init()
    
        apiRoot = URLSURVEY
        apiPaths = NSMutableDictionary(object: URLSURVEY, forKey: "surveys")
        userData = IGUserData()
        
        

    }
    
   public func getApiPaths()->NSDictionary
    {
        return apiPaths
    }
    
   public func getApiUsersPatth()-> NSURL
    {
        return NSURL(string:"http://services.ignidata.com/api/plugin/users")!
    }
    
    public func getApiSurveysPath()-> NSURL
    {
        return NSURL(string:URLSURVEY)!
    }
    
    public func getUserData()->IGUserData
    {
        return userData
    }
    
    public func putUserData()->Bool
    {
        var url:NSURL = getApiUsersPatth()
        var error:NSErrorPointer = NSErrorPointer()
     
        var userTest:NSMutableDictionary = NSMutableDictionary(objectsAndKeys: self.userData.getUserAge(),"age", self.userData.getUserGender(),"gender", self.userData.getUserLanguage(),"language") as NSMutableDictionary
        
        var jsonData:NSData = NSJSONSerialization.dataWithJSONObject(userTest, options: nil, error: error)!
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy:NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 20.0)
        
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(String(format:"%lu", jsonData.length), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = jsonData
        
        var response: NSURLResponse?

        
        
        var returnData:NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)!
        
        
        if let httpResponse = response as? NSHTTPURLResponse
        {
            
            if httpResponse.statusCode == 200
            {
               
                 userData.setValue(NSString(data: returnData, encoding: NSUTF8StringEncoding), forKey: "hash")
                return true
            }
            
            else
            {
                return false
            }
            
        }
        else
        {
            return false
        }
        
    }
    
    public func setSurveysParams(pluginParams:NSMutableDictionary)
    {
        params = pluginParams
    }
    public func setSurveysParamsLocationLatLog(latitude: Float, longitude: Float)
    {
        params.setValue(latitude, forKey: "locationLat")
        params.setValue(longitude, forKey: "locationLong")
    }
    
    public func setSurveysParamsUserHash(userHash:NSString)
    {
        params.setValue(userHash, forKey: "userHash")
    }
    
    
    
   public func getSurveyParams()->NSDictionary
    {
        return params
    }
    
    public func getSurveysParamsData()->NSData    {
        var data = NSData()
        if userData.valueForKey("hash") == nil
        {
           return data
        }
        
        return data
    
}
    
   public func createGetSurveysRequest(data:NSData)->NSURLRequest
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var main:IGMainViewController = IGMainViewController()
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: getApiSurveysPath())
        var request1:NSMutableURLRequest = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(String(format:"%lu", data.length), forHTTPHeaderField: "Content-Lenght")
        
        request.HTTPBody = data
        
        var response: NSURLResponse?
        var error: NSError?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
 
        
        if let httpResponse = response as? NSHTTPURLResponse {
           if httpResponse.statusCode == 200
           {
                request1 = request
            }
            
            else
           {
              main.delegateSurvey?.surveySucess("102")
            }
        
        }
        
        
        
       return request1
    
    }
    
   public func handleWebViewRequest(request:NSMutableURLRequest)->Bool
    {
        return true
    }
    
   public func surveySubmitWith(request:NSURLRequest)->Bool
    {
        var response = NSHTTPURLResponse()
        var error:NSError? = nil
        
        
        
        if response.statusCode == 200
        {
            
            return true
            
            
        }
        else
        {
            if response.statusCode==302
            {
                var newURL = NSString()
                // newURL = response.allHeaderFields["key-name"]?.stringValue!
            }
            
            return false
        }

    }
}

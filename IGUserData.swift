//
//  IGUserData.swift
//  ignidataSurveyPlugin
//
//  Created by Andre Muchagata on 10/08/2015.
//  Copyright (c) 2015 Andre Muchagata. All rights reserved.
//

import Foundation
import CoreLocation
import Security
import CoreFoundation


public class IGUserData:NSObject, CLLocationManagerDelegate
{
    
    var userData:NSMutableDictionary = NSMutableDictionary()
    var locManager = CLLocationManager()
    
    var age:NSString = NSString()
    var gender:NSString=NSString()
    var language=NSString()
    
    var userID = NSString()
    
    var prefs = NSUserDefaults.standardUserDefaults()

    override init() {
        super.init()
        userData = loadUserData()
        startLocalization()
        
        
    }
    public func startLocalization()->Bool
    {
        locManager = CLLocationManager()
        if !CLLocationManager.locationServicesEnabled()
        {
           
            return false
        }
        else
        {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locManager.distanceFilter = 100.0
            locManager.startUpdatingLocation()
            return true
        
        }
    }
    
    public func getUserHash() -> NSString
    {
        return userData.valueForKey("hash") as! NSString
    }
    
    public func getUserData() -> NSMutableDictionary
    {
        return userData
    }
    
    public func getUserGender()->NSString
    {
        return (userData["gender"] as? NSString) ?? ""

    }
    
    public  func setUserGender(gender:NSString)
    {
        userData.setValue(gender, forKey: "gender")
    }
    
    public func stopAndRetrieveLocation()->CLLocation
    {
            locManager.stopUpdatingLocation()
            return locManager.location
    }
    
    
    public func getUserAge()->NSString
    {
       
    return  (userData["age"] as? NSString) ?? ""
      
    }
    
    public func setUserAge(age:NSString)
    {
        return userData.setValue(age, forKey: "age")
    }
    
    public func getUserLanguage()->NSString
    {
        return (userData["country"] as? NSString) ?? ""

    }
    
    public func setUserLanguage(language:NSString)
    {
        return userData.setValue(language, forKey: "country")
    }
    
    public func loadUserData()->NSMutableDictionary
    {
     
        var dict = prefs.dictionaryForKey("IGUserHash")
        if dict == nil
        {
            return NSMutableDictionary()
        }
        else
        {
            var loaded = NSMutableDictionary()
            loaded.setDictionary(dict!)
            
            return loaded
            
        }
    }
    
    
    public func storeUserData()
    {
            var dict = NSMutableDictionary()
            dict.setDictionary(userData as [NSObject : AnyObject])
        
            prefs.setObject(dict, forKey: "IGUserHash")
    
    }
    
    
    
    
}

//
//  IGTokenManager.swift
//  ignidataSurveyPlugin
//
//  Created by Andre Muchagata on 18/08/2015.
//  Copyright (c) 2015 Andre Muchagata. All rights reserved.
//

import Foundation

public class IGTokenManager:NSObject
{
    override init() {
        super.init()
    }
    
    public class func saveAccessToken(token:IGAccessToken)
    {
        IGJNKeyChain.save("user_login_token",data:token.token)
        IGJNKeyChain.save("user_login_expireDate", data: "user_login_expireDate")
        IGJNKeyChain.save("user_login_tokentype", data:token.token_type)
    }
    
    public class func loadAccessToken()->IGAccessToken
    {
        var token:IGAccessToken = IGAccessToken()
                
        token.token = IGJNKeyChain.load("user_login_token") as! NSString
        token.expire_Date = IGJNKeyChain.load("user_login_expireDate") as! NSDate
        token.token_type = IGJNKeyChain.load("user_login_tokentype") as! NSString
        
        return token
        
        
    }
    
    public class func deleteKeyChain()
    {
        
        IGJNKeyChain.delete("user_login_token")
        IGJNKeyChain.delete("user_login_expireDate")
        IGJNKeyChain.delete("user_login_tokentype")
    
    }
}
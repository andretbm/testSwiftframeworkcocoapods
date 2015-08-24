//
//  IGAccessToken.swift
//  ignidataSurveyPlugin
//
//  Created by Andre Muchagata on 18/08/2015.
//  Copyright (c) 2015 Andre Muchagata. All rights reserved.
//

import Foundation

public class IGAccessToken:NSObject
{
    var token:NSString = ""
    var token_type:NSString = ""
    var expire_Date:NSDate = NSDate()
}
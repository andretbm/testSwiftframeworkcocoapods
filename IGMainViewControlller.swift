//
//  IGMainViewControlller.swift
//  ignidataSurveyPlugin
//
//  Created by Andre Muchagata on 10/08/2015.
//  Copyright (c) 2015 Andre Muchagata. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import CoreGraphics
import MobileCoreServices
import JavaScriptCore
import WebKit

public protocol IGMainDelegate
{
   func surveySucess(successString:NSString)
    
}

public class IGMainViewController:UIViewController,UIAlertViewDelegate, UIPickerViewDelegate, UITextFieldDelegate, UIWebViewDelegate,UIGestureRecognizerDelegate
{

    let FAKE_IT = true
    let RESULT_SUCCESS:String  = "100"
    let RESULT_CANCEL:String = "101"
    let RESULT_ERROR:String  = "102"
    let RESULT_INVALID:String  = "103"
    let RESULT_ERROR_INTERNET:String  = "104"
    let RESULT_FILL_FORM:String  = "105"
   
    public var delegateSurvey : IGMainDelegate?
    
    
 
    let MARGIN_SMALL:Double = 4.0
    let MARGIN:Double = 7.0
    let MARGIN_BIG:Double = 10.0
    let MARGIN_DOUBLE:Double = 12.0
    let buttonsHeight:Double = 24.0
    
    let SURVEY_STARTING = 0
    //#define SURVEY_NEW_USER 1
    let SURVEY_USER_MENU = 2
    let SURVEY_LOADING = 3
    let SURVEY_QUESTIONS = 4
    let SURVEY_ENDED  = 5
    
    
    let  UNITY3D = "200"
    
    let  UNITYGAMEOBJECT  = "unityAnchorObject"
    
    var timer = NSTimer()
    
    var state = Int()
    var unity3D = NSString()
    var gameObject = NSString()
    
    //View
    var popupView = UIView()
    var menuPopupView = UIView()
    var agePicker = UIPickerView()
    var genderPicker = UIPickerView()
    var languagePicker = UIPickerView()
    var webView = UIWebView()

    
    //Button
    var menuButton = UIButton()
    var surveyButton = UIButton()
    var cancelButton = UIButton()
   
    //TextFields
    var ageTextField = UITextField()
    var languageTextField = UITextField()
    var genderTextField = UITextField()
   
    //Arrays
    var pickerAgeData = NSArray()
    var pickerGenderData = NSArray()
    var pickerLanguageData = NSArray()
        
   public func initWithPrice(price: Double, message: String)->Self
    {
        
            let survey = IGSurveySDK()

            state = SURVEY_STARTING
            
            survey.setSurveysParams(NSMutableDictionary(object: price, forKey: "pricepoint"))
            
            return self
      
    }
        
      
  public func initData()
    {
        self.pickerAgeData=NSArray(objects:"18-24","25-34","35-44","45-54","55+")
        self.pickerGenderData=NSArray(objects: "Male","Female","Other")
        self.pickerLanguageData=NSArray(objects:"English")
    
    }
     override public func viewDidLoad() {
        var survey = IGSurveySDK()

        super.viewDidLoad()
        
        
      if Reachability.isConnectedToNetwork() == false
      {
        delegateSurvey?.surveySucess(RESULT_ERROR_INTERNET)
      
        
        }
        else
      {
        if state == SURVEY_STARTING
        {
   
            
            initData()
           
           if survey.getUserData().getUserData().count != 0
           {
            state = SURVEY_LOADING
            initSurveyPopup()
           
            }
            else
           {
            state = SURVEY_USER_MENU
               initMenuPopup()
              showMenu()
            
          }
       }
        
        
        var gestureRecognizerAge:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"agePickerTapped:")
        var gestureRecognizerGender:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"genderPickerTapped:")
        var gestureRecognizerLanguage:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"languagePickerTapped:")
        
        gestureRecognizerAge.delegate = self
        gestureRecognizerGender.delegate=self
        gestureRecognizerLanguage.delegate=self
        
                    
        agePicker.addGestureRecognizer(gestureRecognizerAge)
        genderPicker.addGestureRecognizer(gestureRecognizerGender)
        languagePicker.addGestureRecognizer(gestureRecognizerLanguage)
        }

    }
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func agePickerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        
        var touchPoint:CGPoint = gestureRecognizer .locationInView(gestureRecognizer.view?.superview)
        var frame:CGRect = agePicker.frame
        var selectorFrame:CGRect = CGRectInset(frame, 0.0, agePicker.bounds.size.height * 0.85 / 2.0)
        
        if CGRectContainsPoint(selectorFrame, touchPoint)
        {
            ageTextField.text = pickerAgeData .objectAtIndex(agePicker.selectedRowInComponent(0)) as! String
            self.view .endEditing(true)
        }
        
        
        
    }
    
    public func genderPickerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        var touchPoint:CGPoint = gestureRecognizer .locationInView(gestureRecognizer.view?.superview)
        var frame:CGRect = genderPicker.frame
        var selectorFrame:CGRect = CGRectInset(frame, 0.0, genderPicker.bounds.size.height * 0.85 / 2.0)
        
        if CGRectContainsPoint(selectorFrame, touchPoint)
        {
            genderTextField.text = pickerGenderData .objectAtIndex(genderPicker.selectedRowInComponent(0)) as! String
            self.view .endEditing(true)
        }

    }
    
    public func languagePickerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        var touchPoint:CGPoint = gestureRecognizer .locationInView(gestureRecognizer.view?.superview)
        var frame:CGRect = languagePicker.frame
        var selectorFrame:CGRect = CGRectInset(frame, 0.0, languagePicker.bounds.size.height * 0.85 / 2.0)
        
        if CGRectContainsPoint(selectorFrame, touchPoint)
        {
            languageTextField.text = pickerLanguageData .objectAtIndex(languagePicker.selectedRowInComponent(0)) as! String
            self.view .endEditing(true)
        }
        
    }

 
   public func setupPopup(popup:UIView, size:CGSize)
    {
        popup.frame = CGRect(x: CGFloat(MARGIN_DOUBLE), y:CGFloat(MARGIN_DOUBLE*2), width:CGFloat(size.width)-CGFloat(2*MARGIN_DOUBLE), height:CGFloat(size.height)-CGFloat(4*MARGIN_DOUBLE))
        
        popup.backgroundColor = UIColor.grayColor()
        popup.layer.cornerRadius = 5
        popup.layer.masksToBounds = true
        popup.layer.borderWidth = 1.0
        popup.layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
    
   public func loadSurvey()
   {
        var spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.center = self.view.center
    
        self.view .addSubview(spinner)
        UIApplication .sharedApplication().networkActivityIndicatorVisible=true
    
        self.view.endEditing(true)
        initSurveyPopup()
        state = SURVEY_LOADING
    
    
    
    }
    
   @IBAction public func surveyButtonAction(sender:UIButton!)
    {
        var survey = IGSurveySDK()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
              
        if ageTextField.text.isEmpty  || genderTextField.text.isEmpty
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if unity3D == UNITY3D
            {
                closeWithMessage(RESULT_FILL_FORM)
            }
            else
            {
                delegateSurvey?.surveySucess(RESULT_FILL_FORM)
            }
           
            
        }
        
        else
        {
          if  Reachability.isConnectedToNetwork()==false
          {
            delegateSurvey?.surveySucess(RESULT_ERROR_INTERNET)
          }
            else
            
          {
             UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            surveyButton.enabled = false
            
            var user = IGUserData()
            user.getUserData()
            
            user.setUserAge(ageTextField.text)
            user.setUserGender(genderTextField.text)
            user.setUserLanguage(languageTextField.text)
            
            if FAKE_IT
            {
               

                survey.getUserData().getUserData().setValue("hashtreta", forKey: "hash")
                  UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                loadSurvey()
            }
            else
            {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                if survey.putUserData() == true
                {

                    loadSurvey()
                }
                else
                {
                     UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                   
                   surveyErrorAction()
                }
            
        }
        
        
        }
     }
        
    }

   public func initSurveyPopup()
    {
       

        let survey = IGSurveySDK()
        if popupView != ""
        {
            popupView.removeFromSuperview()
            
            
        }
       
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
       
        popupView = UIView()
        
        popupView.frame = CGRectMake(CGFloat(MARGIN_DOUBLE), CGFloat(MARGIN_DOUBLE*2), CGFloat(self.view.bounds.width-CGFloat(2*MARGIN_DOUBLE)), CGFloat(self.view.bounds.size.height-CGFloat(4*MARGIN_DOUBLE)))
        
        popupView.backgroundColor = UIColor.clearColor()
        popupView.layer.cornerRadius = 5
        popupView.layer.masksToBounds = true
        popupView.layer.borderWidth = 1.0;
        popupView.layer.borderColor = UIColor.clearColor().CGColor
        
        var popupSize:CGSize = CGSize()
        
        popupSize = popupView.bounds.size
        
        menuButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        menuButton.tintColor = UIColor.whiteColor()
        menuButton.addTarget(self, action:"menuButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        menuButton.setTitle("Menu", forState: UIControlState.Normal)
        menuButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        menuButton.frame = CGRectMake(CGFloat(MARGIN), CGFloat(popupSize.height) - CGFloat(MARGIN) - CGFloat(buttonsHeight), CGFloat(popupSize.width/2) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(buttonsHeight))
        
        var cancelButton1 = UIButton()
        
        cancelButton1 =  UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
    
        cancelButton1.tintColor = UIColor.whiteColor()
        cancelButton1.addTarget(self, action:"cancelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton1.setTitle("Cancel", forState: UIControlState.Normal)
         cancelButton1.titleLabel?.textAlignment = NSTextAlignment.Center
        
          cancelButton1.frame = CGRectMake(CGFloat(MARGIN) + CGFloat(popupSize.width/4) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(popupSize.height) - CGFloat(MARGIN) - CGFloat(buttonsHeight), CGFloat(popupSize.width) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(buttonsHeight))
        
        webView.frame = CGRectMake(CGFloat(popupView.frame.origin.x)-CGFloat(MARGIN_BIG*2.4), 0, CGFloat(self.view.frame.size.width), CGFloat(popupSize.height) - CGFloat(MARGIN_DOUBLE + buttonsHeight))
        
        
        webView.delegate = self;
        webView.scrollView.bounces = false
        webView.opaque = false;
        
        webView.loadRequest(survey.createGetSurveysRequest(survey.getSurveysParamsData()))
        
        popupView.addSubview(menuButton)
        popupView.addSubview(cancelButton1)
        
    }
    
     @IBAction public func menuButtonAction(sender:UIButton!)
    {
        showMenu()
        timer.invalidate()
        state = SURVEY_USER_MENU
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_CANCEL)
        }
        else
        {
            delegateSurvey?.surveySucess(RESULT_CANCEL)
        }
        reloadSurvey()
    }
    
    @IBAction public func cancelButtonAction(sender:UIButton)
    {
       
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_CANCEL)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            delegateSurvey?.surveySucess(RESULT_CANCEL)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        reloadSurvey()
        
        
    }
    
    public func reloadSurvey()
    {
        ageTextField.text = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        genderTextField.text=nil
        showMenu()
        agePicker.reloadAllComponents()
        agePicker.selectedRowInComponent(0)
        genderPicker.reloadAllComponents()
        genderPicker.selectedRowInComponent(0)

    }
    
    
   public func initMenuPopup()
    {
        if menuPopupView != ""
        {
            menuPopupView.removeFromSuperview()
        }
        
        menuPopupView = UIView()
        view.backgroundColor = UIColor.whiteColor()
        setupPopup(menuPopupView, size: self.view.bounds.size)
        
        surveyButton.enabled = true
        cancelButton.enabled = true
        
        var currHeight:Double = MARGIN_DOUBLE
        
        var titleLabel = UILabel(frame: CGRect(x:0, y:0, width: CGFloat(menuPopupView.bounds.size.width), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
     
        titleLabel.text = "Insert user data"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(CGFloat(14))
        
        titleLabel.sizeToFit()
       
        titleLabel.center = CGPointMake(menuPopupView.bounds.size.width / 2, titleLabel.center.y)
        
        
        currHeight += Double(titleLabel.frame.size.height) + MARGIN
        
        
        var headerView = UIView (frame: CGRect(x: 0, y:0, width: CGFloat(menuPopupView.bounds.size.width), height:CGFloat(currHeight)))
    
        headerView.backgroundColor = UIColor.darkGrayColor();
        
        var separator = UIView(frame:CGRect(x: 0, y: CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width), height: CGFloat(MARGIN_SMALL)))
        
        separator.backgroundColor = UIColor.blueColor()
        
        currHeight += Double(separator.frame.size.height) + MARGIN_DOUBLE
        
        var ageLabel = UILabel(frame:CGRect(x:CGFloat(MARGIN), y: CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        ageLabel.text = "Age "
        
        ageLabel.textColor = UIColor.whiteColor()
        
        ageLabel.font = UIFont.systemFontOfSize(CGFloat(11))
            
        ageLabel.sizeToFit()

        currHeight += Double(ageLabel.frame.size.height) + MARGIN
        
        
        ageTextField = UITextField (frame:CGRect(x: CGFloat(4*MARGIN), y: CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width-CGFloat(5*MARGIN)), height: CGFloat(buttonsHeight)))
        ageTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        agePicker = UIPickerView()
        
        agePicker.tag = 1
        
        agePicker.delegate = self
        
        ageTextField.tag = 1
        
        ageTextField.inputView = agePicker
        
        ageTextField.delegate = self
        
        agePicker.reloadAllComponents()
        
        ageTextField.placeholder = "Inser age"
        
        currHeight += Double(ageTextField.frame.size.height) + MARGIN_DOUBLE
        
        var genderLabel = UILabel(frame:CGRect(x:CGFloat(MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(5*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        genderLabel.text = "Gender"
        
        genderLabel.textColor = UIColor.whiteColor()
        
        genderLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        
        genderLabel.sizeToFit()

        currHeight += Double(genderLabel.frame.size.height) + MARGIN
        
        genderTextField = UITextField (frame: CGRect(x: CGFloat(4*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(5*MARGIN), height:CGFloat(buttonsHeight)))
        
        genderTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        genderPicker = UIPickerView()
        
        genderPicker.tag = 2
        
        genderPicker.delegate = self
        
        genderTextField.tag = 2
        
        genderTextField.inputView = genderPicker
        
        genderTextField.delegate = self
        
        genderPicker.reloadAllComponents()
        
        genderTextField.placeholder = "Insert Gender"
        
        currHeight += Double(genderTextField.frame.size.height) + MARGIN_DOUBLE
        
        var languageLabel = UILabel(frame:CGRect(x: CGFloat(MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        languageLabel.text = "Language"
        languageLabel.textColor = UIColor.whiteColor()
        
        languageLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        
        languageLabel.sizeToFit()
        
        currHeight += Double(languageLabel.frame.size.height) + MARGIN
        
        
        languageTextField = UITextField(frame: CGRect(x:CGFloat(4*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(5*MARGIN), height: CGFloat(buttonsHeight)))
        
        languageTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        languagePicker = UIPickerView()
        
        languagePicker.tag = 3
        
        languagePicker.delegate = self
        languageTextField.inputView = languagePicker
        
        languageTextField.tag = 3
        
        languageTextField.delegate = self
        
        languagePicker.reloadAllComponents()
        
        languageTextField.text = pickerView(languagePicker, titleForRow: 0, forComponent: 0)

        currHeight += Double(languageTextField.frame.size.height) + (MARGIN*3)
        
        
        surveyButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        surveyButton.tintColor = UIColor.whiteColor()
        
        surveyButton.frame = CGRect(x: CGFloat(menuPopupView.bounds.size.width/4), y:CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width/2), height: CGFloat(30))
        
        surveyButton.setTitle("Go to survey", forState: UIControlState.Normal)
        
        surveyButton.addTarget(self, action: "surveyButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
      
    

        currHeight += Double(languageTextField.frame.size.height) + MARGIN_DOUBLE
        
        cancelButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        cancelButton.tintColor = UIColor.whiteColor()
        cancelButton.frame = CGRect(x: CGFloat(menuPopupView.bounds.size.width/4), y: CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width/2), height: CGFloat(30))
        
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        menuPopupView.addSubview(titleLabel)
        menuPopupView.addSubview(separator)
        menuPopupView.addSubview(ageLabel)
        menuPopupView.addSubview(ageTextField)
        menuPopupView.addSubview(genderLabel)
        menuPopupView.addSubview(genderTextField)
        menuPopupView.addSubview(languageLabel)
        menuPopupView.addSubview(languageTextField)
        menuPopupView.addSubview(surveyButton)
        menuPopupView.addSubview(cancelButton)

        view.addSubview(menuPopupView)
        
       
    }
    
  public func showMenu()
    {
        surveyButton.enabled=true
        cancelButton.enabled=true
        popupView.removeFromSuperview()
        ageTextField.text = nil
        agePicker.reloadAllComponents()
        agePicker.selectedRowInComponent(0)
        genderPicker.reloadAllComponents()
        languagePicker.reloadAllComponents()
        genderPicker.selectedRowInComponent(0)
        genderTextField.text = nil
      
        self.view.addSubview(menuPopupView)
        state = SURVEY_USER_MENU
        
    }
    
  public func hideMenu()
    {
        menuPopupView.removeFromSuperview()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
   public func closeWithMessage(msg:NSString)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
     public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        
        if (request.mainDocumentURL?.relativePath == "/success/true" )
        {
            
            if unity3D == UNITY3D
            {
                closeWithMessage(RESULT_SUCCESS)
            }
            
    
            else
            {
               showMenu()

              delegateSurvey?.surveySucess(RESULT_SUCCESS)
            }
        
                       
            
            return false
           
            
        }
            
        else if navigationType == UIWebViewNavigationType.FormSubmitted
        {
            delegateSurvey?.surveySucess(RESULT_SUCCESS)
            return false
            
        }
        
        else
        {
            if request.mainDocumentURL?.relativePath == "/success/false"
            {
                
            }
        }
        
        return true
    }
    
   public  
     func webViewDidStartLoad(webView: UIWebView) {
     
          UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: "surveyTimeoutAction", userInfo: nil, repeats: false)
    }
   public  
     func webViewDidFinishLoad(webView: UIWebView)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        popupView.addSubview(webView)
        
        self.view.addSubview(popupView)
        
        timer.invalidate()
        
        var context:JSContext = JSContext()
        
        context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext")as! JSContext
        
        var block : @objc_block (NSString!) -> Void = {
            (string : NSString!) -> Void in
            
            self.submitSurvey(string)
        }
        
        context.setObject(unsafeBitCast(block, AnyObject.self), forKeyedSubscript: "submitButton")
        
        
    }
    
    
  public func submitSurvey(param1:NSString)
    {
        self.dismissViewControllerAnimated(false, completion: nil)
        ageTextField.text = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        genderTextField.text=nil
                showMenu()
        agePicker.reloadAllComponents()
        agePicker.selectedRowInComponent(0)
        genderPicker.reloadAllComponents()
        genderPicker.selectedRowInComponent(0)
        state = SURVEY_ENDED

        if unity3D ==  UNITY3D
        {
            closeWithMessage(RESULT_SUCCESS)
        }
        else
        {
            delegateSurvey?.surveySucess(RESULT_SUCCESS)

        }
    }
   public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
    
        timer.invalidate()
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        surveyErrorAction()
    
    
    }
    
    
  public func surveyErrorAction()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_ERROR)
        }
        else
        {
            delegateSurvey?.surveySucess(RESULT_ERROR)
        }
        reloadSurvey()        
        
        surveyButton.enabled=true
        cancelButton.enabled=true
        timer.invalidate()
    }
    
     public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        if pickerView.tag==1
        {
            return  self.pickerAgeData.objectAtIndex(row) as! NSString as String

        }
        else if pickerView.tag == 2
        {
            return self.pickerGenderData.objectAtIndex(row) as! NSString as String
        }
            
        else if pickerView.tag == 3
        {
            return self.pickerLanguageData.objectAtIndex(row) as! NSString as String
        }
        
        else
        {
            return ""
        }
        
    }
   public  
     func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        

        if pickerView.tag == 1
        {
            ageTextField.text = pickerAgeData.objectAtIndex(row) as! String
            
            ageTextField.resignFirstResponder()
        }
        else if pickerView.tag == 2
        {
            genderTextField.text = pickerGenderData.objectAtIndex(row) as! String
            genderTextField.resignFirstResponder()
        }
        
        else if pickerView.tag == 3
        {
            languageTextField.text = pickerLanguageData.objectAtIndex(row) as! String
            genderTextField.resignFirstResponder()
        }
    
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
       
        if pickerView.tag==1
        {
            return pickerAgeData.count
        }
        else if pickerView.tag==2
        {
            return pickerGenderData.count
        }
        
        else if pickerView.tag==3
        {
            return pickerLanguageData.count
        }
        else
        {
            return 0
        }
    }
    
    
     override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
   public  
     func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1
        {
            if ageTextField.text == ""
            {
                ageTextField.text = pickerAgeData.objectAtIndex(0) as! String
            }
            
            ageTextField.resignFirstResponder()
        }
        else if textField.tag == 2
        {
            if genderTextField.text == ""
            {
                genderTextField.text = pickerGenderData.objectAtIndex(0) as! String
                
            }
            genderTextField.resignFirstResponder()
        }
        
        else if textField.tag == 3
        {
            if languageTextField.text == ""
            {
                languageTextField.text = pickerLanguageData.objectAtIndex(0) as! String
            }
        }
    
    }
    
    
     override public func shouldAutorotate() -> Bool {
        return false
    }
    
    
     override public func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if state == SURVEY_QUESTIONS
        {
            initSurveyPopup()
        }
        else
        {
            initMenuPopup()
        }
        
    }
    
    

    
    
   
    
    
}
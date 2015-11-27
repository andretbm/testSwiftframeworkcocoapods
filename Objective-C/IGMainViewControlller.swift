/*
Copyright (c) 2015 IGNIDATA Team - https://github.com/ignidata

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */



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
    
    let survey = IGSurveySDK()
 
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
    
    var country = NSString()
    var city = NSString()
    
    let  UNITY3D = "200"
    
    let  UNITYGAMEOBJECT  = "unityAnchorObject"
    
    var invalidPostalCode = NSString()
    var invalidProfession = NSString()
    
    var timer = NSTimer()
    
    var state = Int()
    var unity3D = NSString()
    var gameObject = NSString()
    var request = NSURLRequest()
    
    //View
    var popupView = UIView()
    var menuPopupView = UIView()
    var agePicker = UIDatePicker()
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
    var professionTextField = UITextField()
    var zipCodeTextField = UITextField()
   
    //Arrays
    var pickerGenderData = NSArray()
    var pickerLanguageData = NSArray()
    
    public func initWithPrice(price: Double, message: String)->Self
    {
      
        
        if Reachability.isConnectedToNetwork() == false
        {
            errorInternet()
        }
        else
        {
        
            if(survey.getUserID().length != 0)
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                initSurveyPopup()
            }
            else
            {
                state = SURVEY_STARTING
                survey.setSurveysParams(NSMutableDictionary(object: price, forKey: "pricepoint"))
            
                
            }
       
        
      }
        return self
      
    }
        
      
  public func initData()
    {
        self.pickerGenderData=NSArray(objects: "Male","Female")
        self.pickerLanguageData=NSArray(objects:"English")
    
    }
     override public func viewDidLoad() {
       let survey = IGSurveySDK()

        super.viewDidLoad()
        

      if Reachability.isConnectedToNetwork() == false
      {
         errorInternet()
      
        
        }
        else
        {
   
            if survey.getUserID().length == 0
           {
            initData()

           
            initMenuPopup()
            
            
          }
            
            else
            {
              
              initSurveyPopup()
                

            }
        let gestureRecognizerAge:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"agePickerTapped:")
        let gestureRecognizerGender:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"genderPickerTapped:")
        let gestureRecognizerLanguage:UITapGestureRecognizer = UITapGestureRecognizer (target: self, action:"languagePickerTapped:")
        
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
        let touchPoint:CGPoint = gestureRecognizer.locationInView(gestureRecognizer.view?.superview)
        
        let frame:CGRect = agePicker.frame
        let selectorFrame:CGRect = CGRectInset(frame, 0.0, agePicker.bounds.size.height * 0.85 / 2.0)
      
        if(CGRectContainsPoint( selectorFrame, touchPoint) )
        {
            
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            let formatedDate:NSString = dateFormatter.stringFromDate(agePicker.date)
            
           ageTextField.text = formatedDate as String
            self.view.endEditing(true)
        }
        
        
    }
    
    public func genderPickerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let touchPoint:CGPoint = gestureRecognizer .locationInView(gestureRecognizer.view?.superview)
        let frame:CGRect = genderPicker.frame
        let selectorFrame:CGRect = CGRectInset(frame, 0.0, genderPicker.bounds.size.height * 0.85 / 2.0)
        
        if CGRectContainsPoint(selectorFrame, touchPoint)
        {
            genderTextField.text = pickerGenderData .objectAtIndex(genderPicker.selectedRowInComponent(0)) as? String
            self.view .endEditing(true)
        }

    }
    
    public func languagePickerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let touchPoint:CGPoint = gestureRecognizer .locationInView(gestureRecognizer.view?.superview)
        let frame:CGRect = languagePicker.frame
        let selectorFrame:CGRect = CGRectInset(frame, 0.0, languagePicker.bounds.size.height * 0.85 / 2.0)
        
        if CGRectContainsPoint(selectorFrame, touchPoint)
        {
            languageTextField.text = pickerLanguageData .objectAtIndex(languagePicker.selectedRowInComponent(0)) as? String
            self.view .endEditing(true)
        }
        
    }

 
   public func setupPopup(popup:UIView, size:CGSize)
    {
        popup.frame = CGRect(x: CGFloat(MARGIN_DOUBLE), y:CGFloat(MARGIN_DOUBLE*2), width:CGFloat(size.width)-CGFloat(2*MARGIN_DOUBLE), height:CGFloat(size.height)-CGFloat(4*MARGIN_DOUBLE))
        
        popup.backgroundColor = UIColor.whiteColor()
        popup.layer.cornerRadius = 5
        popup.layer.masksToBounds = true
        popup.layer.borderWidth = 1.0
        popup.layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
   @IBAction public func surveyButtonAction(sender:UIButton!)
    {
        
        
              
        if ageTextField.text!.isEmpty  || genderTextField.text!.isEmpty || zipCodeTextField.text!.isEmpty || professionTextField.text!.isEmpty
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if unity3D == UNITY3D
            {
                closeWithMessage(RESULT_FILL_FORM)
            }
            else
            {
                
               
                self.showAlertError(0)
                
            }
           
            
        }
        
        else
        {
          if  Reachability.isConnectedToNetwork()==false
          {
            errorInternet()
          }
            
            
        else
            
          {
           if(invalidPostalCode.isEqualToString("invalid"))
           {
                self.showAlertError(1)
           }
            else if(invalidProfession.isEqualToString("invalid"))
           {
                self.showAlertError(2)
           }
           else
           {
            
            
            survey.userInfo.setValuesForKeysWithDictionary(["birthdate" : ageTextField.text! , "gender":genderTextField.text!, "language" : languageTextField.text!, "profession" : professionTextField.text!, "postalcode" : zipCodeTextField.text!, "city":self.city, "country":self.country])
            
            self.view.endEditing(true)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            surveyButton.enabled = false
                   
                  
           initSurveyPopup()
          }
        }
     }
        
    }

   public func initSurveyPopup()
    {
    
        if popupView != ""
        {
            popupView.removeFromSuperview()
        }
       
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
       
        popupView = UIView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        popupView.frame = CGRectMake(CGFloat(MARGIN_DOUBLE), CGFloat(MARGIN_DOUBLE*2), CGFloat(self.view.bounds.width-CGFloat(2*MARGIN_DOUBLE)), CGFloat(self.view.bounds.size.height-CGFloat(4*MARGIN_DOUBLE)))
        
        
        popupView.backgroundColor = UIColor.clearColor()
        popupView.layer.cornerRadius = 5
        popupView.layer.masksToBounds = true
        popupView.layer.borderWidth = 1.0;
        popupView.layer.borderColor = UIColor.clearColor().CGColor
        
        var popupSize:CGSize = CGSize()
        
        popupSize = popupView.bounds.size
        
        menuButton = UIButton(type: UIButtonType.System)
        
        menuButton.tintColor = UIColor.blackColor()
        menuButton.addTarget(self, action:"menuButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        menuButton.setTitle("Menu", forState: UIControlState.Normal)
        menuButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        menuButton.frame = CGRectMake(CGFloat(MARGIN), CGFloat(popupSize.height) - CGFloat(MARGIN) - CGFloat(buttonsHeight), CGFloat(popupSize.width/2) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(buttonsHeight))
        
        var cancelButton1 = UIButton()
        
        cancelButton1 =  UIButton(type: UIButtonType.System)
        
    
        cancelButton1.tintColor = UIColor.blackColor()
        cancelButton1.addTarget(self, action:"cancelButtonActionInsideSurvey:", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton1.setTitle("Cancel", forState: UIControlState.Normal)
         cancelButton1.titleLabel?.textAlignment = NSTextAlignment.Center
        
          cancelButton1.frame = CGRectMake(CGFloat(MARGIN) + CGFloat(popupSize.width/4) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(popupSize.height) - CGFloat(MARGIN) - CGFloat(buttonsHeight), CGFloat(popupSize.width) - CGFloat(MARGIN_DOUBLE / 2), CGFloat(buttonsHeight))
        
        webView.frame = CGRectMake(CGFloat(popupView.frame.origin.x)-CGFloat(MARGIN_BIG*2.4), 0, CGFloat(self.view.frame.size.width), CGFloat(popupSize.height) - CGFloat(MARGIN_DOUBLE + buttonsHeight))
        
        
        webView.delegate = self;
        webView.scrollView.bounces = false
        webView.opaque = false;
    
        webView.loadRequest(survey.createGetSurveysRequest())
        
        webView.backgroundColor = UIColor.whiteColor()
        
        
      
        popupView.addSubview(menuButton)
        popupView.addSubview(cancelButton1)
        
    }
    
     @IBAction public func menuButtonAction(sender:UIButton!)
    {
       
        timer.invalidate()
     
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_CANCEL)
        }
        else
        {
            
            self.showAlertError(3)
        
        }
      
    }
    
    @IBAction public func cancelButtonAction(sender:UIButton)
    {
       
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_CANCEL)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        else
        {
            
            self.showAlertError(3)
            
        }
        
        reloadSurvey()
        
        
    }
    
    @IBAction public func cancelButtonActionInsideSurvey(sender:UIButton)
    {
        
        if unity3D == UNITY3D
        {
            closeWithMessage(RESULT_CANCEL)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            self.showAlertError(3)
        }
    }

    
    public func reloadSurvey()
    {
        ageTextField.text = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        genderTextField.text=nil
        professionTextField.text = nil
        zipCodeTextField.text = nil
        showMenu()
       
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
        menuPopupView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        setupPopup(menuPopupView, size: self.view.bounds.size)
        
        surveyButton.enabled = true
        cancelButton.enabled = true
        
        var currHeight:Double = MARGIN_DOUBLE
        
        let titleLabel = UILabel(frame: CGRect(x:0, y: CGFloat(2*MARGIN), width: CGFloat(menuPopupView.bounds.size.width), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
     
        titleLabel.text = "Insert user data"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.systemFontOfSize(CGFloat(14))
        
        titleLabel.sizeToFit()
       
        titleLabel.center = CGPointMake(menuPopupView.bounds.size.width / 2, titleLabel.center.y)
        
        
        currHeight += Double(titleLabel.frame.size.height) + MARGIN
        
        
        let headerView = UIView (frame: CGRect(x: 0, y:0, width: CGFloat(menuPopupView.bounds.size.width), height:CGFloat(currHeight)))
    
        headerView.backgroundColor = UIColor.whiteColor();
        
        let separator = UIView(frame:CGRect(x: 0, y: CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width), height: CGFloat(MARGIN_SMALL)))
        
        separator.backgroundColor = UIColor.whiteColor()
        
        currHeight += Double(separator.frame.size.height) + MARGIN_DOUBLE
        
        let ageLabel = UILabel(frame:CGRect(x:CGFloat(2*MARGIN), y: CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        ageLabel.text = "Age"
        
        ageLabel.textColor = UIColor.blackColor()
        
        ageLabel.font = UIFont.systemFontOfSize(CGFloat(11))
            
        ageLabel.sizeToFit()

        currHeight += Double(ageLabel.frame.size.height) + MARGIN
        
        
        ageTextField = UITextField (frame:CGRect(x: CGFloat(2*MARGIN), y: CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width-CGFloat(5*MARGIN)), height: CGFloat(buttonsHeight)))
        ageTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        agePicker = UIDatePicker()
        
        agePicker.tag = 1
        
        let todayDate:NSDate = NSDate()
        
    
        agePicker.maximumDate = todayDate;
        
        agePicker.datePickerMode = UIDatePickerMode.Date
        
        ageTextField.tag = 1
        
        ageTextField.inputView = agePicker
        
        ageTextField.delegate = self
        
        ageTextField.placeholder = "Inser age"
        
        currHeight += Double(ageTextField.frame.size.height) + MARGIN_DOUBLE
        
        let genderLabel = UILabel(frame:CGRect(x:CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(5*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        genderLabel.text = "Gender"
        
        genderLabel.textColor = UIColor.blackColor()
        
        genderLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        
        genderLabel.sizeToFit()

        currHeight += Double(genderLabel.frame.size.height) + MARGIN
        
        genderTextField = UITextField (frame: CGRect(x: CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(5*MARGIN), height:CGFloat(buttonsHeight)))
        
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
        
        let languageLabel = UILabel(frame:CGRect(x: CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        languageLabel.text = "Language"
        languageLabel.textColor = UIColor.blackColor()
        
        languageLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        
        languageLabel.sizeToFit()
        
        currHeight += Double(languageLabel.frame.size.height) + MARGIN
        
        
        languageTextField = UITextField(frame: CGRect(x:CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(5*MARGIN), height: CGFloat(buttonsHeight)))
        
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
        
        
        let professionLabel = UILabel(frame:CGRect(x: CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        professionLabel.text = "Profession"
        professionLabel.textColor = UIColor.blackColor()
        professionLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        professionLabel.sizeToFit()

        currHeight += Double(professionLabel.frame.size.height) + MARGIN

        professionTextField =  UITextField(frame: CGRect(x:CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(5*MARGIN), height: CGFloat(buttonsHeight)))
        
        professionTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        professionTextField.tag = 4
        
        professionTextField.delegate = self
        
        professionTextField.placeholder = "Insert your profession"
        
        currHeight += Double(professionTextField.frame.size.height) + (MARGIN*3)
        
        
        let zipCodeLabel = UILabel(frame:CGRect(x: CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width)-CGFloat(4*MARGIN), height: CGFloat(menuPopupView.bounds.size.height/2)))
        
        zipCodeLabel.text = "Postal Code"
        
        zipCodeLabel.textColor = UIColor.blackColor()
        
        zipCodeLabel.font = UIFont.systemFontOfSize(CGFloat(11))
        
        zipCodeLabel.sizeToFit()
        
        currHeight += Double(zipCodeLabel.frame.size.height) + MARGIN
        
        
        zipCodeTextField =  UITextField(frame: CGRect(x:CGFloat(2*MARGIN), y:CGFloat(currHeight), width:CGFloat(menuPopupView.bounds.size.width) - CGFloat(5*MARGIN), height: CGFloat(buttonsHeight)))
        
        zipCodeTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        zipCodeTextField.tag = 5
        
        zipCodeTextField.delegate = self
        
        zipCodeTextField.placeholder = "Insert your postal code"
        
        currHeight += Double(zipCodeTextField.frame.size.height) + MARGIN_DOUBLE


        surveyButton = UIButton(type: UIButtonType.System)
        
        surveyButton.tintColor = UIColor.blackColor()
        
        surveyButton.frame = CGRect(x: CGFloat(menuPopupView.bounds.size.width/4), y:CGFloat(currHeight), width: CGFloat(menuPopupView.bounds.size.width/2), height: CGFloat(30))
        
        surveyButton.setTitle("Go to survey", forState: UIControlState.Normal)
        
        surveyButton.addTarget(self, action: "surveyButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)

        currHeight += Double(surveyButton.frame.size.height) + MARGIN_DOUBLE
        
        cancelButton = UIButton(type: UIButtonType.System)
        
        cancelButton.tintColor = UIColor.blackColor()
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
        menuPopupView.addSubview(professionLabel)
        menuPopupView.addSubview(professionTextField)
        menuPopupView.addSubview(zipCodeLabel)
        menuPopupView.addSubview(zipCodeTextField)
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
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
        if (request.mainDocumentURL?.relativePath == "/success/true" )
        {
            
            if unity3D == UNITY3D
            {
                closeWithMessage(RESULT_SUCCESS)
            }
            
    
            else
            {

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
     
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: "surveyTimeoutAction", userInfo: nil, repeats: false)
    }
   public  
     func webViewDidFinishLoad(webView: UIWebView)
    {
     
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let test:Bool = Bool()
        popupView.addSubview(webView)
        
        self.view.addSubview(popupView)
        
        
        let user:IGUserData = IGUserData()
        
 
        
        let userID:String = webView.stringByEvaluatingJavaScriptFromString("$('[name^=\"participant_id\"]').val()")!
        
    
        
        if(user.loadUserData().length == 0 && userID != "")
        {
            user.storeUserData(userID as String)

        }
        
        
        
              
        timer.invalidate()
        
        var context:JSContext = JSContext()
        
        context = webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext")as! JSContext
        
              let block : @convention(block) (NSString!) -> Void = {
            (string : NSString!) -> Void in
                
             if Reachability.isConnectedToNetwork() == false
             {
                  self.errorInternet()
                }
                
                else
                {
                    
                    
//                    let value:Int = Int(webView.stringByEvaluatingJavaScriptFromString("$('[id^=\"qtype-\"]').length")!)!;
//                    
//                    
//                    var resp:Int = value
//
//                    for var i = 0; i < value; ++i{
//                      
//                        
//                        if webView.stringByEvaluatingJavaScriptFromString(String(format:"$('[id^=\"qtype-%d\"]').val()",i+1)) == "single"
//                        {
//                            if webView.stringByEvaluatingJavaScriptFromString(String(format:"document.querySelector('input[name=\"a_%d\"]:checked').value;",i+1))?.isEmpty == false
//                            {
//                                resp = resp-1
//                            }
//                        }
//                         if  webView.stringByEvaluatingJavaScriptFromString(String(format:"$('[id^=\"qtype-%d\"]').val()",i)) == "multi"
//                        {
//                            if webView.stringByEvaluatingJavaScriptFromString(String(format:"document.querySelector('input[name=\"a_%d\"]:checked').value;",i))?.isEmpty == false
//                            {
//                                resp = resp-1
//                            }
//                        }
//                         if  webView.stringByEvaluatingJavaScriptFromString(String(format:"$('[id^=\"qtype-%d\"]').val()",i)) == "open"
//                        {
//                            if webView.stringByEvaluatingJavaScriptFromString(String(format:"document.querySelector('textarea[name=\"a_%d\"]:checked').value;",i))?.isEmpty == false
//                            {
//                                resp = resp-1
//                            }
//                        }
//                        
//                        if  webView.stringByEvaluatingJavaScriptFromString(String(format:"$('[id^=\"qtype-%d\"]').val()",i)) == "rating"
//                        {
//
//                            let val:Int =   (Int((webView.stringByEvaluatingJavaScriptFromString(String(format:"$('[name^=\"ai-%d\"]').length",i)))!))!
//                            
//                                                      
//                          
//                            
//                            for var j=0 ; j<val; ++j
//                            {
//                        if(Int((webView.stringByEvaluatingJavaScriptFromString(String(format:"document.querySelector('input[id=\"sr-%d-a%d\"]').value;",i,j))!)))>0
//                               {
//                                    resp = resp - 1
//                                }
//                                
//                            }
//                            
//                        }
//                        
//                        
//                      
//                    }
//                    
//                    if resp == 0
//                    {
                        self.submitSurvey(test)

//                    }
//                    else
//                    {
//                       resp = value
//                    }
                    
                  
                }
    
        }
        
        context.setObject(unsafeBitCast(block, AnyObject.self), forKeyedSubscript: "submitButton")
        
        
    }
    
    
  public func submitSurvey(param1:Bool)
    {
//        if param1 == true
//        {
            self.dismissViewControllerAnimated(false, completion: nil)
                ageTextField.text = nil
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            genderTextField.text=nil
                showMenu()
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
   public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
    
        timer.invalidate()
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        self.dismissViewControllerAnimated(false, completion: nil)
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
            self.showAlertError(4)
        }
    }
    
     public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 2
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
    
        if pickerView.tag == 2
        {
            genderTextField.text = pickerGenderData.objectAtIndex(row) as? String
            genderTextField.resignFirstResponder()
        }
        
        else if pickerView.tag == 3
        {
            languageTextField.text = pickerLanguageData.objectAtIndex(row) as? String
            genderTextField.resignFirstResponder()
        }
    
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
       
        if pickerView.tag==2
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
    
    
     override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
   public  
     func textFieldDidEndEditing(textField: UITextField) {
        
        if textField.tag == 1
        {
            ageTextField.resignFirstResponder()
        }
        else if textField.tag == 2
        {
            if genderTextField.text == ""
            {
                genderTextField.text = pickerGenderData.objectAtIndex(0) as? String
                
            }
            genderTextField.resignFirstResponder()
        }
        
        else if textField.tag == 3
        {
            if languageTextField.text == ""
            {
                languageTextField.text = pickerLanguageData.objectAtIndex(0) as? String
            }
        }
        else if textField.tag == 4
        {
            if(professionTextField.text != nil)
            {
               if( self.validateProfession(professionTextField.text!) == false)
               {
                    self.showAlertError(5)
                }
            }
        }
        else if textField.tag == 5
        {
            if (zipCodeTextField.text != nil)
            {
                getInformationByPostalCode(zipCodeTextField.text!)
            }
        }
    }
    
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
    
        return true
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
    
    public func surveyTimeoutAction()
    {
        
    }
    
    public func errorInternet()
    {
       self.showAlertError(6)
    }
    
    
    public func validatePostalCode(postalCode:NSString)->Bool
    {
        
        let predicate:String = "(?i)^[a-z0-9][a-z0-9- ]{0,10}[a-z0-9]$"
        
       return  NSPredicate(format: "SELF MATCHES %@", predicate).evaluateWithObject(postalCode)
    }
    
    public func validateProfession(profession:NSString)->Bool
    {
        let predicate:String = "[a-zA-Z]+"
        
         return  NSPredicate(format: "SELF MATCHES %@", predicate).evaluateWithObject(profession)
        
        
    }
    
    public func getInformationByPostalCode(postalCode:NSString)->Void
    {
        
        if(self.validatePostalCode(postalCode))
        {
            let url = String(format:"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",postalCode)
        
            let getPostal:NSURL = NSURL(string:url)!
        
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: getPostal)
        
            request.HTTPMethod = "GET"
            var response: NSURLResponse?
            let urlData:NSData = try! NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        
            let string:NSString = "OK"
      
        
        
        
            let countries:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(urlData, options: [])) as! NSDictionary
        
            if countries.valueForKey("status") as! String == string
            {
                let array:NSArray = countries.valueForKey("results")?.valueForKey("address_components")?.valueForKey("long_name")?.objectAtIndex(0) as! NSArray
            
                let count:Int = array.count
                country = array.objectAtIndex(count-1) as! String
                city = array.objectAtIndex(count-2) as! String
            }
        
            else
            {
            
            }
        }
        else
        {
            self.showAlertError(1)
            
            invalidPostalCode = "invalid"

        }
              
    }
    
    
    public func showAlertError(tag:Int)->Void
    {
        
        var alert:UIAlertController!
        if tag == 0
        {
             alert = UIAlertController(title: "Empty Fields", message: "Sorry to proceed with the survey you have to fill in all the required fields", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
        }
        
        if tag == 1
        {
            alert = UIAlertController(title: "Invalid postal code", message: "Please insert a valid postal code", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
           

        }
        
        if tag == 2
        {
             alert = UIAlertController(title: "Invalid profession", message: "Please insert a valid profession", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
           

        }
        
        if tag == 3
        {
            
           alert = UIAlertController(title: nil, message: "Do you really want to cancel?", preferredStyle: .Alert)
            
            // Create the actions
            let yesAction = { (action:UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
            // Add the actions
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.Default, handler: yesAction))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil))
            // Present the controller

        }
        
        if tag == 4
        {
             alert = UIAlertController(title: "Error with the servers", message: "We are sorry but our servers are unavailable at this time please try again later", preferredStyle: UIAlertControllerStyle.Alert)
            
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        if tag == 5
        {
             alert = UIAlertController(title: "Invalid profession", message: "Please insert a valid profession", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        }
        
        if tag == 6
        {
             alert = UIAlertController(title: "Problems with internet connection", message: "Please check your internet connection to proceed", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            

        }
            
        self.presentViewController(alert, animated: true, completion: nil)
        
       
    }
    
   
    
    
}
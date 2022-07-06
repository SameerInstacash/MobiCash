//
//  AppConstant.swift
//  InstaCashApp
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON


var AppUserName = "planetm"
var AppApiKey = "fd9a42ed13c8b8a27b5ead10d054caaf"

var AppBaseUrl = "https://xcover-uat.getinstacash.in/xtracoverexchange/api/v1/public/" // Staging
//var AppBaseUrl = "https://sellncash.xtracover.com/xtracoverexchange/api/v1/public/" // Live

var AppBaseTnc = "https://xcover-uat.getinstacash.in/xtracoverexchange/tnc.php"  // Staging
//var AppBaseTnc = "https://sellncash.xtracover.com/xtracoverexchange/tnc.php"  // Live


// Api Name
let kStartSessionURL = "startSession"
let kGetProductDetailURL = "getProductDetail"
let kUpdateCustomerURL = "updateCustomer"
let kGetSessionIdbyIMEIURL = "getSessionIdbyIMEI"
let kPriceCalcNewURL = "priceCalcNew"
let kSavingResultURL = "savingResult"
let kIdProofURL = "idProof"
let kgetMaxisForm = "getMaxisForm"
let ksetMaxisForm = "setMaxisForm"
let kCheckTradeinVoucher = "checkTradeinVoucher"
let kRemoveTradeinVoucher = "removeTradeinVoucher"

var AppCurrentProductBrand = ""
var AppCurrentProductName = ""
var AppCurrentProductImage = ""

var hardwareQuestionsCount = 0
var AppQuestionIndex = -1

var AppHardwareQuestionsData : CosmeticQuestions?
var arrAppHardwareQuestions: [Questions]?
var arrAppQuestionsAppCodes : [String]?


// ***** App Tests Performance ***** //
var holdAppTestsPerformArray = [String]()
var AppTestsPerformArray = [String]()
var AppTestIndex : Int = 0

let AppUserDefaults = UserDefaults.standard
var AppResultJSON = JSON()
var AppResultString = ""




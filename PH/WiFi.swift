//
//  Wifi.swift
//  PH
//
//  Created by qmc on 16/11/3.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

import UIKit
import CoreTelephony.CTTelephonyNetworkInfo
import SystemConfiguration.CaptiveNetwork

// 'CNCopyCurrentNetworkInfo' was deprecated in iOS 9.0: For captive network applications, this has been completely replaced by <NetworkExtension/NEHotspotHelper.h>. For other applications, there is no direct replacement. Please file a bug describing your use of this API to that we can consider your requirements as this situation evolves.


enum NetworkReachable {
    case Can, Not
}

enum NetworkType {
    case Unknown, Cellular2G, Cellular3G, Cellular4G
}

class WiFi: NSObject {
    
    var reachable: NetworkReachable {
        get {
            return isNetworkReachable()
        }
    }
    
    var networkType: NetworkType {
        get {
            return currentNetworkType()
        }
    }

   func getMac()->(success: Bool, ssid: String, mac: String) {
    
        if let interfaces = CNCopySupportedInterfaces() {
            let if0: UnsafePointer<Void>? = CFArrayGetValueAtIndex(interfaces, 0)
            let interfaceName: CFStringRef = unsafeBitCast(if0!, CFStringRef.self)
//            print(interfaces)
//            print(CNCopyCurrentNetworkInfo(interfaceName))
            let ssidNSdic = CFBridgingRetain(CNCopyCurrentNetworkInfo(interfaceName))
//            print(ssidNSdic.self)
            var ssid = String()
            var bssid = String()
            if ssidNSdic != nil { //未连接WiFi的情况会返回nil
                ssid = ssidNSdic!["SSID"] as! String
                bssid = ssidNSdic!["BSSID"] as! String
                return (true, ssid, bssid)
            }
        }
        return (false, "", "")
    }
    
    /**
     设备注册无线接入技术
     
     - returns: Unknown, Cellular2G, Cellular3G, Cellular4G
     */
    func currentNetworkType()->NetworkType {
      
        let networkType = CTTelephonyNetworkInfo().currentRadioAccessTechnology
        if networkType == nil { //
            return .Unknown
        } else {
            
            switch networkType! {
                
            case CTRadioAccessTechnologyGPRS:
                
                return .Cellular2G
                
            case CTRadioAccessTechnologyEdge:
                
                return .Cellular2G // 2.75G的EDGE网络
                
            case CTRadioAccessTechnologyWCDMA:
                
                return .Cellular3G
                
            case CTRadioAccessTechnologyHSDPA:
                
                return .Cellular3G // 3.5G网络
                
            case CTRadioAccessTechnologyHSUPA:
                
                return .Cellular3G // 3.5G网络
                
            case CTRadioAccessTechnologyCDMA1x:
                
                return .Cellular2G // CDMA2G网络
                
            case CTRadioAccessTechnologyCDMAEVDORev0,
                 
                 CTRadioAccessTechnologyCDMAEVDORevA,
                 
                 CTRadioAccessTechnologyCDMAEVDORevB:
                
                return .Cellular3G
                
            case CTRadioAccessTechnologyeHRPD:
                
                return .Cellular3G // 电信的怪胎，只能算3G
                
            case CTRadioAccessTechnologyLTE:
                
                return .Cellular4G
                
            default:
                
                return .Unknown
                
            }
        }
    }
    
    func isNetworkReachable()->NetworkReachable {
        
        var isCellularReachable = false // 设备是否注册无线接入技术
        let networkType = CTTelephonyNetworkInfo().currentRadioAccessTechnology
        if networkType == nil { // 非蜂窝网络下会返回nil
            isCellularReachable = false
        } else {
            isCellularReachable = true
        }
        
        /**
         *  there are total three condition
         *  1. not reachable, 2.cellular, 3.wifi
         */
        var isWifiReachable = false //wifi 是否连接了
        if self.getMac().success {
            isWifiReachable = true
        } else {
            isWifiReachable = false
        }
        
        if !isCellularReachable && !isWifiReachable{
            return .Not
        } else {
            return .Can
        }
    }
    
}

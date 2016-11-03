//
//  FELocation.swift
//  PH
//
//  Created by qmc on 16/11/3.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

import UIKit
import CoreLocation

class FELocation: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    override init() {
        super.init()
        initLocationService()
    }
    
    func initLocationService() {
        
        //开发者可以在Info.plist中设置NSLocationUsageDescription说明定位的目的(Privacy - Location Usage Description)
//        let status = CLLocationManager.authorizationStatus()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // 设置定位的精确度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 设置定位变化的最小距离 距离过滤器
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        //这个是在ios8之后才有的 请求授权
        /**
         
         *用户授权请求
         
         *requestAlwaysAuthorization只要app在运行，请求允许使用定位服务
         
         *requestWhenInUseAuthorization，只有app在前台运行时，请求允许使用定位服务
         
         *需要注意的是，要在plist文件中进行键值的配置，前者是NSLocationAlwaysUsageDescription
         
         *后者是：NSLocationWhenInUseUsageDescription
         
         *若没有对应的键值配置，定位服务无法启动
         
         */
        locationManager.requestAlwaysAuthorization()
        
        //
        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
        } else {
            print("没定位服务")
        }
    }
}

private typealias delegateExtension = FELocation

extension delegateExtension {
    // 定位更新地理信息调用的代理方法
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            manager.stopUpdatingLocation()
            let locationInfo = locations.last!
            print("locationInfo:\(locationInfo)")
            let gcj02 = JZLocationConverter.wgs84ToGcj02(locationInfo.coordinate)
            
//            let alert:UIAlertView = UIAlertView(title: "获取的地理坐标",message: "经度是：\(locationInfo.coordinate.longitude)，维度是：\(locationInfo.coordinate.latitude)",delegate: nil, cancelButtonTitle: "是的")
//            alert.show()
//
            let alert:UIAlertView = UIAlertView(title: "获取的地理坐标",message: "经度是：\(gcj02.longitude)，维度是：\(gcj02.latitude)",delegate: nil, cancelButtonTitle: "是的")
            alert.show()

            let geocoder: CLGeocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(locationInfo, completionHandler: { (array, error) in
                if array?.count > 0 {
                    let placemark: CLPlacemark = array![0]
//                    print(placemark)
                    print("name: \(placemark.name)")
                    print("city: \(placemark.locality)")
//                    print("city: \(placemark.locality)")
                    // 直辖市
                    print("administrativeArea: \(placemark.administrativeArea)")
                    
                }
            })
            
            
            
        }
    }
    
    // 定位失败调用的代理方法
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    //权限发生变化
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("Authorization status changed to \(status.rawValue)")
        
        switch (status) {
            
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            
            self.locationManager.startUpdatingLocation()
            
        case .Denied, .NotDetermined, .Restricted:
            
            self.locationManager.stopUpdatingLocation()
            break;
        }
    }

    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
    //关于指定区域的状态
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
    }
    
    //告诉委托一个或多个信标范围
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
    }
    //告诉委托发生错误而收集一套信标测距信息
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        
    }
    //用户进入指定的区域
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    //用户离开指定区域。
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    //如果试图监视某个特定区域时发生错误，则位置管理器将此消息发送给它的委托。区域监测可能会失败，因为该地区本身无法进行监测，或因为有一个更普遍的故障，在配置该地区的监测服务。虽然这种方法的实现是可选的，但建议您在应用程序中使用区域监控时实现它。
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        
    }
       //一个新区域正在被监视
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        
    }
    
    //当位置管理器检测到该设备的位置不发生变化时，它可以暂停交付的更新，以关闭适当的硬件和节省电力。当它这样做时，它调用这个方法让你的应用程序知道，这已经发生了。
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        
    }
    
    // 当位置更新被暂停，需要恢复（也许是因为用户再次移动），位置管理器调用这个方法让你的应用程序知道，它将开始再次交付这些更新。
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        
    }
    //位置管理器对象调用这个方法来让你知道，它已经停止推迟交货地点的事件。经理可能会称这种方法为任何数量的原因。例如，它要求你停止位置更新，总之，当你问经理的位置不允许延期更新，或者当条件延迟更新（如超过超时或距离参数）会。
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        
    }
    //当有新的访问事件报告给您的应用程序时，位置管理器调用此方法调用此方法。
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
}

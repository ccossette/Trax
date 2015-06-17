//
//  AppDelegate.swift
//  Trax
//
//  Created by Carlo Cossette on 2015-06-15.
//  Copyright (c) 2015 C Cossette. All rights reserved.
//

import UIKit

struct GPXURL
{
    static let Notification = "GPX Notification System"
    static let Key = "GPXURL URL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.Notification, object: self, userInfo: [GPXURL.Key: url])
        center.postNotification(notification)
        return true
    }
}


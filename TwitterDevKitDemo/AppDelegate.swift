/*****************************************************************************
 *
 * FILE:	AppDelegate.swift
 * DESCRIPTION:	TwitterDevKitDemo: Application Main Controller
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Mon, Nov 26 2018
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2017-2018 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2017-2018 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: AppDelegate.m,v 1.6 2017/04/12 09:59:00 kouichi Exp $
 *
 *****************************************************************************/

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder
{
  public fileprivate(set) var themeColor: UIColor? = nil

  var window: UIWindow?

  override init() {
    super.init()
    self.configureAppearance()
  }
}

extension AppDelegate: UIApplicationDelegate
{
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    // Create full-screen window
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window!.backgroundColor = self.themeColor

    // Make root view controller
    self.window!.rootViewController = RootViewController()

    // Show window
    self.window!.makeKeyAndVisible()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    /*
     * Sent when the application is about to move from active to inactive state.
     * This can occur for certain types of temporary interruptions (such as an
     * incoming phone call or SMS message) or when the user quits
     * the application and it begins the transition to the background state.
     * Use this method to pause ongoing tasks, disable timers, and invalidate
     * graphics rendering callbacks. Games should use this method to pause
     * the game.
     */
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    /*
     * Use this method to release shared resources, save user data,
     * invalidate timers, and store enough application state information
     * to restore your application to its current state in case it is
     * terminated later.
     * If your application supports background execution, this method is called
     * instead of applicationWillTerminate: when the user quits.
     */
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    /*
     * Called as part of the transition from the background to the active state;
     * here you can undo many of the changes made on entering the background.
     */
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    /*
     * Restart any tasks that were paused (or not yet started)
     * while the application was inactive. If the application was previously
     * in the background, optionally refresh the user interface.
     */
  }

  func applicationWillTerminate(_ application: UIApplication) {
    /*
     * Called when the application is about to terminate.
     * Save data if appropriate. See also applicationDidEnterBackground:.
     */
  }
}

extension AppDelegate
{
  func configureAppearance() {
    // #1da1f2
    let barColor: UIColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    UINavigationBar.appearance().barTintColor = barColor
    UITabBar.appearance().barTintColor = barColor
    UIToolbar.appearance().barTintColor = barColor
    UISearchBar.appearance().barTintColor = barColor

    UISegmentedControl.appearance().tintColor = barColor
    UIStepper.appearance().tintColor = barColor
    UISwitch.appearance().onTintColor = barColor

    UINavigationBar.appearance().titleTextAttributes = [ .foregroundColor : UIColor.white ]
    UINavigationBar.appearance().tintColor = UIColor.white
    self.themeColor = barColor

    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).setTitleTextAttributes([ .foregroundColor : UIColor.white ], for: [])

    UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = barColor
  }
}

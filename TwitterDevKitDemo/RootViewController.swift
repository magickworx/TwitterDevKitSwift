/*****************************************************************************
 *
 * FILE:	RootViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: Twitter View Controller
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Mon, Jun 26 2017
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2017 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2017 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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
import Accounts
import TwitterDevKit

class RootViewController: BaseViewController
{
  let imageView: UIImageView = UIImageView()

  var twitterAccount: ACAccount? = nil
  var twitter: TDKTwitter? = nil

  override func setup() {
    super.setup()

    self.title = "TwitterDevKitDemo"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func loadView() {
    super.loadView()

    self.view.backgroundColor = self.app.themeColor

    if let image = self.image(with: "★") {
      let x: CGFloat = 0.0
      let y: CGFloat = 0.0
      let w: CGFloat = image.size.width
      let h: CGFloat = image.size.height
      imageView.frame = CGRect(x: x, y: y, width: w, height: h)
      imageView.center = self.view.center
      imageView.image = image
    }
    self.view.addSubview(imageView)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.isHidden = false
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    DispatchQueue.once(token: "com.magickworx.TwitterDevKitDemo") {
      launchAnimation()
    }
  }
}

extension RootViewController
{
  func signIn() {
    acquireAccount(completion: { (accounts: [ACAccount]) -> Void in
      DispatchQueue.main.async() { [weak self] () -> Void in
        if let weakSelf = self {
          weakSelf.chooseAccount(from: accounts)
        }
      }
    })
  }

  func acquireAccount(completion: @escaping (_ accounts: [ACAccount]) -> Void) {
    let store = ACAccountStore()
    let accountType = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)

    store.requestAccessToAccounts(with: accountType, options: nil, completion: {(granted: Bool, error: Error?) -> Void in
      guard error == nil else {
        if let error = error as NSError? {
          self.popup(title: "Error", message: error.localizedDescription)
        }
        else {
          dump(error)
        }
        return
      }
      guard granted else {
        self.popup(title: "Failed", message: "Forbidden")
        return
      }
      let accounts = store.accounts(with: accountType) as! [ACAccount]
      guard accounts.count != 0 else {
        self.popup(title: "Attention", message: "Set your twitter account with Settings.app!")
        return
      }
      completion(accounts)
    })
  }

  func chooseAccount(from accounts: [ACAccount]) {
    let alert = UIAlertController(title: "Twitter", message: "Choose an account", preferredStyle: .actionSheet)

    for account in accounts {
      alert.addAction(UIAlertAction(title: account.username, style: .default, handler: { [weak self] (action) -> Void in
        if let weakSelf = self {
          if let currentAccount = weakSelf.twitterAccount {
            guard currentAccount.username != account.username else {
              return
            }
          }
          weakSelf.twitterAccount = account
          weakSelf.twitter = TDKTwitter(with: account)
          weakSelf.homeTimeline()
        }
      }))
    }

    if let pvc = alert.popoverPresentationController {
      pvc.sourceView = self.view
      if let navigationController = self.navigationController {
        pvc.sourceRect = navigationController.navigationBar.frame
      }
      else {
        let w: CGFloat = self.view.bounds.size.width
        let h: CGFloat = self.view.bounds.size.height
        let x: CGFloat = floor(w * 0.5)
        let y: CGFloat = floor(h * 0.5)
        pvc.sourceRect = CGRect(x: x, y: y, width: 1.0, height: 1.0)
      }
      pvc.permittedArrowDirections = .down
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

extension RootViewController
{
  func homeTimeline() {
    if let twitter = self.twitter, let account = self.twitterAccount {
      let viewController = HomeViewController(with: twitter, account: account)
      viewController.delegate = self
      let navigationController = UINavigationController(rootViewController: viewController)
      self.change(to: navigationController)
    }
  }

  func change(to viewController: UIViewController) {
    let completionBlock = { [weak self] (finished: Bool) -> Void in
      if let weakSelf = self {
        if let fromViewController = weakSelf.childViewControllers.first {
          viewController.didMove(toParentViewController: weakSelf)
          fromViewController.removeFromParentViewController()
        }
      }
    }

    if let fromViewController = self.childViewControllers.first {
      self.addChildViewController(viewController)
      self.transition(from: fromViewController,
                        to: viewController,
                  duration: 0.0,
                   options: [],
                animations: nil,
                completion: completionBlock)
    }
    else {
      self.addChildViewController(viewController)
      self.view.addSubview(viewController.view)
      viewController.didMove(toParentViewController: self)
    }
  }
}

extension RootViewController: HomeViewControllerDelegate
{
  func homeViewControllerWillChangeAccount(_ viewController: HomeViewController) -> Void {
    signIn()
  }
}

extension RootViewController
{
  func launchAnimation() {
    let zoomInAnimations = { [weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      }
    }
    let zoomOutAnimations = { [weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.imageView.transform = CGAffineTransform(scaleX: 10.0, y: 10.0)
        weakSelf.imageView.alpha = 0.0
      }
    }
    let completionClosure = { [weak self] (finished: Bool) -> Void in
      UIView.animate(withDuration: 1.0,
                     delay: 0.0,
                     options: .curveEaseOut,
                     animations: zoomOutAnimations,
                     completion: { [weak self] (finished: Bool) -> Void in
                       if let weakSelf = self {
                          weakSelf.imageView.removeFromSuperview()
                          weakSelf.signIn()
                        }
                     })
    }
    UIView.animate(withDuration: 0.5,
                   delay: 1.0,
                   options: .curveEaseOut,
                   animations: zoomInAnimations,
                   completion: completionClosure)
  }
}

extension RootViewController
{
  /*
   * Reference:
   * http://ios.ch3cooh.jp/entry/20140730/1406694860
   */
  func image(with text: String) -> UIImage? {
    let   size: CGSize  = CGSize(width: 64.0, height: 64.0)
    let opaque: Bool    = false
    let  scale: CGFloat = 0.0

    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

    let shadow = NSShadow()
    shadow.shadowOffset = CGSize(width: 0.0, height: -0.5)
    shadow.shadowColor = UIColor.darkGray
    shadow.shadowBlurRadius = 0.0

    let font = UIFont.boldSystemFont(ofSize: 32.0)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.lineBreakMode = .byClipping

    let attributes: [String:Any] = [
      NSFontAttributeName: font,
      NSParagraphStyleAttributeName: paragraphStyle,
      NSShadowAttributeName: shadow,
      NSForegroundColorAttributeName: UIColor.white
    ]

    let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    text.draw(in: rect, withAttributes:attributes)

    var image: UIImage? = nil
    if let textImage = UIGraphicsGetImageFromCurrentImageContext() {
      image = textImage
    }

    UIGraphicsEndImageContext()

    return image
  }
}

/*
 * swift3 - Dispatch once in Swift 3 - Stack Overflow
 * https://stackoverflow.com/questions/37886994/dispatch-once-in-swift-3
 */
public extension DispatchQueue
{
  private static var _onceTracker = [String]()

  /**
    Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
    only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
  */
  public class func once(token: String, block: (Void) -> Void) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    if _onceTracker.contains(token) {
      return
    }
    _onceTracker.append(token)
    block()
  }
}

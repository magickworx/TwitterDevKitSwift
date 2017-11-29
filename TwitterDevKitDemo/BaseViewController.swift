/*****************************************************************************
 *
 * FILE:	BaseViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: Application Base View Controller
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Wed, Nov 29 2017
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
import AVKit
import AVFoundation
import Social
import SafariServices
import TwitterDevKitSwift
#if !DISABLE_SOCIAL_ACCOUNT_KIT
import SocialAccountKitSwift
#endif // DISABLE_SOCIAL_ACCOUNT_KIT

class BaseViewController: UIViewController
{
  public internal(set) var app: AppDelegate = UIApplication.shared.delegate as! AppDelegate

  public var isNetworkActivityIndicatorVisible: Bool {
    set {
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
      }
    }
    get {
      return UIApplication.shared.isNetworkActivityIndicatorVisible
    }
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  init() {
    super.init(nibName: nil, bundle: nil)
    setup()
  }

  override func loadView() {
    super.loadView()

    self.edgesForExtendedLayout = []
    self.extendedLayoutIncludesOpaqueBars = true

    self.view.backgroundColor = .white
    self.view.autoresizesSubviews = true
    self.view.autoresizingMask	= [ .flexibleWidth, .flexibleHeight ]
  }

  func setup() {
    // actual contents of init(). subclass can override this.
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let composeItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                      target: self,
                                      action: #selector(self.composeAction))
    self.navigationItem.rightBarButtonItem = composeItem
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension BaseViewController
{
  public func popup(title: String, message: String) {
    autoreleasepool {
      let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }

  public func showModal(_ viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
    let navigationController = UINavigationController(rootViewController: viewController)
    if let parentNavigationController = self.navigationController {
      parentNavigationController.present(navigationController, animated: true, completion: nil)
    }
    else {
      self.present(navigationController, animated: true, completion: nil)
    }
  }

  public func presentImage(_ image: UIImage) {
    autoreleasepool {
      let viewController = ImageViewController(with: image)
      viewController.modalPresentationStyle = .overCurrentContext
      viewController.modalTransitionStyle = .crossDissolve
      viewController.view.backgroundColor = .black
      self.showModal(viewController, animated: true, completion: nil)
    }
  }

  public func presentImage(_ image: UIImage, with media: [TDKMedia]) {
    if media.isEmpty {
      self.presentImage(image)
    }
    else {
      if let mediaUrlHttps = media.first?.mediaUrlHttps {
        var urlString = mediaUrlHttps
        if let sizes = media.first?.sizes {
          if sizes.large != nil {
            urlString += ":large"
          }
          else if sizes.medium != nil {
            urlString += ":medium"
          }
          else if sizes.small != nil {
            urlString += ":small"
          }
        }
        TDKImageCacheLoader.shared.fetchImage(with: urlString, cachedTime: 180, completion: {
          [weak self] (fetchedImage: UIImage?, error: Error?) in
          if let weakSelf = self {
            if let image = fetchedImage {
              weakSelf.presentImage(image)
            }
            else {
              weakSelf.presentImage(image)
            }
          }
        })
      }
    }
  }
}

extension BaseViewController
{
  func playback(with urlStr: String) {
    autoreleasepool {
      if let url = URL(string: urlStr) {
        let videoPlayer = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = videoPlayer
        self.present(playerController, animated: true, completion: {
          [unowned self] in
          self.addPlaybackNotification(for: videoPlayer)
          videoPlayer.play()
        })
      }
    }
  }

  func playbackVideo(_ media: TDKMedia) {
    guard let videoInfo = media.videoInfo else { return }
    for variant in videoInfo.variants {
      if let contentType = variant.contentType, let urlStr = variant.url,
         variant.bitrate == 0 { // XXX: bitrate == 0 is streaming.
        if contentType == "application/x-mpegURL" ||
           contentType == "video/mp4" {
          playback(with: urlStr)
        }
      }
    }
  }

  func addPlaybackNotification(for player: AVPlayer) {
    let center = NotificationCenter.default
    center.addObserver(self,
                       selector: #selector(playerDidFinishPlaying),
                       name: .AVPlayerItemDidPlayToEndTime,
                       object: player.currentItem)
  }

  func removePlaybackNotification() {
    let center = NotificationCenter.default
    center.removeObserver(self,
                          name: .AVPlayerItemDidPlayToEndTime,
                          object: nil)
  }

  @objc func playerDidFinishPlaying(_ notification: Notification) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
      [unowned self] in
      self.dismiss(animated: true, completion: {
        self.removePlaybackNotification()
      })
    })
  }
}

extension BaseViewController
{
  /*
   * ios - Warning: Attempt to present * on * whose view is not in the window
   *       hierarchy - swift - Stack Overflow
   *https://stackoverflow.com/questions/26022756/warning-attempt-to-present-on-whose-view-is-not-in-the-window-hierarchy-s
   */
  func topViewController() -> UIViewController? {
    if var topViewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController {
      while (topViewController.presentedViewController != nil) {
        topViewController = topViewController.presentedViewController!
      }
      return topViewController
    }
    return nil
  }

  public func openSafari(with url: URL) {
    autoreleasepool {
      let viewController = SFSafariViewController(url: url)
      if let topViewController = self.topViewController() {
        topViewController.present(viewController, animated: true, completion: nil)
      }
      else {
        self.present(viewController, animated: true, completion: nil)
      }
    }
  }

  public func openSafari(string urlStr: String) {
    if let url = URL(string: urlStr) {
      self.openSafari(with: url)
    }
  }
}

extension BaseViewController
{
  @objc func composeAction(sender: UIBarButtonItem) {
#if DISABLE_SOCIAL_ACCOUNT_KIT
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
      autoreleasepool {
        if let slc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
          slc.completionHandler = {
            [unowned self] (result: SLComposeViewControllerResult) -> () in
            switch (result) {
            case .done:
              print("tweeted")
            case .cancelled:
              print("tweet cancel")
            }
          }
          present(slc, animated: true, completion: nil)
        }
        else {
          self.popup(title: "Failed", message: "Could not tweet")
        }
      }
    }
#else
    let accountType = SAKAccountType(.twitter)
    if SAKComposeViewController.isAvailable(for: accountType) {
      autoreleasepool {
        let slc = SAKComposeViewController(for: accountType)
        slc.completionHandler = {
          [unowned self] (result: SAKComposeViewControllerResult) -> () in
          switch (result) {
          case .done(_):
            print("tweeted")
          case .cancelled:
            print("tweet cancel")
          case .error(let error):
            self.popup(title: "Error", message: error.localizedDescription)
          }
        }
        present(slc, animated: true, completion: nil)
      }
    }
#endif // DISABLE_SOCIAL_ACCOUNT_KIT
  }
}

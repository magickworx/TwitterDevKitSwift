/*****************************************************************************
 *
 * FILE:	RootViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: Twitter View Controller
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Sat, Jun 24 2017
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
  var progressBar: UIProgressView = UIProgressView()
  var timelineView: TimelineView = TimelineView()

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

    let  width: CGFloat = self.view.bounds.size.width
    let height: CGFloat = self.view.bounds.size.height
    let x: CGFloat = 0.0
    var y: CGFloat = 0.0
    let w: CGFloat = width
    var h: CGFloat = 2.0

    progressBar.frame = CGRect(x: x, y: y, width: w, height: h)
    progressBar.progressTintColor = .orange
    self.view.addSubview(progressBar)

    y = h
    h = height - h
    timelineView.frame = CGRect(x: x, y: y, width: w, height: h)
    timelineView.delegate = self
    self.view.addSubview(timelineView)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    getAccount(completion: { (accounts: [ACAccount]) -> Void in
#if     true
      self.chooseAccount(from: accounts)
#else
      self.twitterAccount = accounts.last
      if let account = self.twitterAccount {
        self.twitter = TDKTwitter(with: account)
      }
      self.getHomeTimeline()
#endif
    })
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.isHidden = false
  }
}

extension RootViewController
{
  func getAccount(completion: @escaping (_ accounts: [ACAccount]) -> Void) {
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
          weakSelf.title = account.username
          weakSelf.twitterAccount = account
          weakSelf.twitter = TDKTwitter(with: account)
          weakSelf.getHomeTimeline()
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
  func handleTimeline(_ timeline: TDKTimeline) {
    progressBar.progress = 0.0
    let  total = timeline.total
    var  count = 0
    var tweets = [AnyObject]()
    for tweet in timeline {
      tweets.append(tweet)
      count += 1
      DispatchQueue.main.async() {
        let progress: Float = Float(count) / Float(total)
        self.progressBar.setProgress(progress, animated: true)
        if progress >= 1.0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressBar.setProgress(0.0, animated: false)
          }
        }
      }
    }
    timelineView.setTimelineData(tweets)
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

  func getHomeTimeline(with sinceId: Int64 = 0) {
    if let twitter = self.twitter {
      let count = 200 // 読み込むツィートの数
      let parameters = TDKHomeTimelineParameters(with: count)
      if sinceId > 0 {
        parameters.sinceId = sinceId
      }
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      twitter.getHomeTimeline(with: parameters, completion: {
        (timeline: TDKTimeline?, error: Error?) in
        if error == nil, let timeline = timeline {
          self.handleTimeline(timeline)
        }
        else {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          dump(error)
        }
      })
    }
  }
}


extension RootViewController: TimelineViewDelegate
{
  func timelineView(_ timelineView: TimelineView, willRefreshSince latestTweet: TDKTweet) -> Void {
    self.getHomeTimeline(with: latestTweet.id)
  }

  func clickableAction(_ action: TDKClickableActionType, in tweet: TDKTweet) {
    switch action {
      case .icon(let user):
        if let twitter = self.twitter, let screenName = user.screenName {
          autoreleasepool {
            let viewController = UserViewController(with: twitter, screenName: screenName)
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        }
        else {
          dump(user)
        }
      case .hashtag(let hashtag, let text):
        if let twitter = self.twitter {
          autoreleasepool {
            let viewController = SearchViewController(with: twitter, query: "#" + text)
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        }
        else {
          dump(hashtag)
        }
      case .media(let media, let text):
        if let expandedUrl = media.expandedUrl {
          self.openSafari(string: expandedUrl)
        }
        if let mediaUrlHttps = media.mediaUrlHttps {
          self.openSafari(string: mediaUrlHttps)
        }
        if let mediaUrl = media.mediaUrl {
          self.openSafari(string: mediaUrl)
        }
        else {
          self.openSafari(string: text)
        }
      case .url(let url, let text):
        if let expandedUrl = url.expandedUrl {
          self.openSafari(string: expandedUrl)
        }
        else {
          self.openSafari(string: text)
        }
      case .mention(let mention, let screenName):
        if let twitter = self.twitter {
          autoreleasepool {
            let viewController = UserViewController(with: twitter, screenName: screenName)
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        }
        else {
          dump(mention)
        }
      case .image(let image):
        self.presentImage(image)
    }
  }

  func timelineView(_ timelineView: TimelineView, didSelect tweet: TDKTweet) {
    /*
     *  ios - Is there any dump() like function returns a string?
     *      - Stack Overflow
     * https://stackoverflow.com/questions/37581828/is-there-any-dump-like-function-returns-a-string
     */
    autoreleasepool {
      var text = String()
      dump(tweet, to: &text)
      let viewController = DumpViewController(with: text)
      self.navigationController?.pushViewController(viewController, animated: true)
    }
  }
}

/*****************************************************************************
 *
 * FILE:	SearchViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: View Controller to Search Tweet
 * DATE:	Wed, Jun 21 2017
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
import TwitterDevKitSwift

class SearchViewController: BaseViewController
{
  var searchBar: UISearchBar = UISearchBar()
  var progressBar: UIProgressView = UIProgressView()
  var timelineView: TimelineView = TimelineView()

  var twitter: TDKTwitter? = nil
  var query: String? = nil

  public convenience init(with twitter: TDKTwitter, query: String) {
    self.init()

    self.twitter = twitter
    self.query = query
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

    if let text = self.query {
      searchBar.text = text
    }
    searchBar.placeholder = "Enter search word"
    searchBar.delegate = self
    searchBar.showsBookmarkButton = true
    self.navigationItem.titleView = searchBar

    self.navigationItem.rightBarButtonItem = nil

    if let query = self.query {
      self.searchTweet(with: query)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.isHidden = false
  }
}

extension SearchViewController
{
  func handleTimeline(_ timeline: TDKTimeline) {
    DispatchQueue.main.async() {
      [unowned self] in
      self.progressBar.progress = 0.0
    }
    let  total = timeline.total
    var  count = 0
    var tweets = [AnyObject]()
    for tweet in timeline {
      tweets.append(tweet)
      count += 1
      DispatchQueue.main.async() {
        [unowned self] in
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
    self.isNetworkActivityIndicatorVisible = false
  }

  func searchTweet(with query: String, sinceId: Int64 = 0) {
    if let twitter = self.twitter {
      self.timelineView.clearTimelineData()
      let count = 20 // 読み込むツィートの数
      var parameters = TDKSearchTweetParameters(q: query, count: count)
      if sinceId > 0 {
        parameters.sinceId = sinceId
      }
      self.isNetworkActivityIndicatorVisible = true
      twitter.searchTweet(with: parameters, completion: {
        (timeline: TDKTimeline?, metadata: JSON?, error: Error?) in
        if error == nil, let timeline = timeline {
          self.handleTimeline(timeline)
        }
        else {
          self.isNetworkActivityIndicatorVisible = false
          dump(error)
        }
      })
    }
  }
}


extension SearchViewController: TimelineViewDelegate
{
  func timelineView(_ timelineView: TimelineView, willRefreshSince latestTweet: TDKTweet) -> Void {
    if let query = self.query {
      self.searchTweet(with: query, sinceId: latestTweet.id)
    }
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
      case .hashtag(_, let text):
        let keyword = "#" + text
        searchBar.text = keyword
        self.searchTweet(with: keyword)
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
      case .image(let media, let image):
        self.presentImage(image, with: media)
      case .video(let media):
        self.playbackVideo(media)
    }
  }

  func timelineView(_ timelineView: TimelineView, didSelect tweet: TDKTweet) {
    autoreleasepool {
      if let text = tweet.prettyPrintedJSONData() {
        let viewController = DumpViewController(with: text)
        self.navigationController?.pushViewController(viewController, animated: true)
      }
    }
  }
}

extension SearchViewController: TweetTableCellDelegate
{
  func tweetAction(_ action: TweetAction, for tweet: TDKTweet, finished: @escaping TweetActionFinishHandler) {
    switch action {
      case .json:
        autoreleasepool {
          if let text = tweet.prettyPrintedJSONData() {
            let viewController = DumpViewController(with: text)
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        }
      default: // XXX: 実際の実装では action 毎のコードを記述する
        finished(true)
        break
    }
  }
}

extension SearchViewController: UISearchBarDelegate
{
  func inactiveSearchBar() {
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
  }

  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }

  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    return true
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.inactiveSearchBar()
    if let text = searchBar.text {
      self.searchTweet(with: "#" + text)
    }
  }

  func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
    self.inactiveSearchBar()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.inactiveSearchBar()
    searchBar.text = ""
  }
}

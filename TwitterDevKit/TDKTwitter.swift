/*****************************************************************************
 *
 * FILE:	TDKTwitter.swift
 * DESCRIPTION:	TwitterDevKit: REST API Wrapper for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Sat, Aug 26 2017
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
 * $Id$
 *
 *****************************************************************************/

import Foundation
import UIKit
import Accounts
import Social

public typealias TDKTimelineCompletionHandler = (TDKTimeline?, Error?) -> Void
public typealias TDKSearchCompletionHandler = (TDKTimeline?, JSON?, Error?) -> Void
public typealias TDKLookupUserCompletionHandler = ([TDKUser], Error?) -> Void

public class TDKTwitter: NSObject
{
  public internal(set) var account: ACAccount? = nil

  public required init(with account: ACAccount) {
    super.init()

    self.account = account
  }
}

// MARK: - Timeline Methods
extension TDKTwitter
{
  public func getHomeTimeline(with parameters: TDKHomeTimelineParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json") {
      self.fetchTimeline(with: requestURL, parameters: parameters?.toJSON(), completion: completion)
    }
  }

  public func getUserTimeline(with parameters: TDKUserTimelineParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json") {
      self.fetchTimeline(with: requestURL, parameters: parameters?.toJSON(), completion: completion)
    }
  }

  func fetchTimeline(with requestURL: URL, parameters: [String:Any]? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: requestURL, parameters: parameters) {
      request.account = self.account
      request.perform(handler: {(responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(with: json)
        }
        completion(timeline, error)
      })
    }
  }
}

// MARK: - Search Methods
extension TDKTwitter
{
  public func searchTweet(with parameters: TDKSearchTweetParameters? = nil, completion: @escaping TDKSearchCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/search/tweets.json") {
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: requestURL, parameters: parameters?.toJSON()) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          var metadata: JSON? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json["statuses"])
            metadata = json["search_metadata"]
          }
          completion(timeline, metadata, error)
        })
      }
    }
  }
}

// MARK: - Favorites Methods
extension TDKTwitter
{
  public func getFavoritesList(with parameters: TDKFavoritesParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/list.json") {
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: requestURL, parameters: parameters?.toJSON()) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json)
          }
          completion(timeline, error)
        })
      }
    }
  }

  public func createFavorites(with statusId: String, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/create.json") {
      let parameters: [String:Any] = [
        "id" : statusId,
        "include_entities" : String(true)
      ]
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: requestURL, parameters: parameters) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json)
          }
          completion(timeline, error)
        })
      }
    }
  }

  public func deleteFavorites(with statusId: String, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/destroy.json") {
      let parameters: [String:Any] = [
        "id" : statusId,
        "include_entities" : String(true)
      ]
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: requestURL, parameters: parameters) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json)
          }
          completion(timeline, error)
        })
      }
    }
  }
}

// MARK: - Statuses Methods
extension TDKTwitter
{
  public func removeTweet(with statusId: String, completion: @escaping TDKTimelineCompletionHandler) {
    let urlString = "https://api.twitter.com/1.1/statuses/destroy/" + statusId + ".json"
    if let requestURL = URL(string: urlString) {
      let parameters: [String:Any] = [
        "id" : statusId,
        "trim_user" : String(false)
      ]
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: requestURL, parameters: parameters) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json)
          }
          completion(timeline, error)
        })
      }
    }
  }

  public func retweet(with statusId: String, count: Int = 100, completion: @escaping TDKTimelineCompletionHandler) {
    let urlString = "https://api.twitter.com/1.1/statuses/retweets/" + statusId + ".json"
    if let requestURL = URL(string: urlString) {
      let parameters: [String:Any] = [
        "id" : statusId,
        "count": String(count < 0 || count > 100 ? 100 : count),
        "trim_user" : String(false)
      ]
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: requestURL, parameters: parameters) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var timeline: TDKTimeline? = nil
          if let jsonData = responseData {
            let json = JSON(jsonData)
            timeline = TDKTimeline(with: json)
          }
          completion(timeline, error)
        })
      }
    }
  }
}

// MARK: - Users Methods
extension TDKTwitter
{
  public func lookupUser(with parameters: TDKLookupUserParameters, completion: @escaping TDKLookupUserCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/users/lookup.json") {
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: requestURL, parameters: parameters.toJSON()) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var users = [TDKUser]()
          if let jsonData = responseData {
            let json = JSON(jsonData)
            for user in json {
              users.append(TDKUser(user))
            }
          }
          completion(users, error)
        })
      }
    }
  }

  public func showUser(with parameters: TDKLookupUserParameters, completion: @escaping TDKLookupUserCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/users/show.json") {
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: requestURL, parameters: parameters.toJSON()) {
        request.account = self.account
        request.perform(handler: { (responseData, urlResponse, error) in
          var users = [TDKUser]()
          if let jsonData = responseData {
            let user = JSON(jsonData)
            users.append(TDKUser(user))
          }
          completion(users, error)
        })
      }
    }
  }
}

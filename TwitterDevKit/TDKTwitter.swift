/*****************************************************************************
 *
 * FILE:	TDKTwitter.swift
 * DESCRIPTION:	TwitterDevKit: REST API Wrapper for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Tue, Nov 14 2017
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
#if DISABLE_SOCIAL_ACCOUNT_KIT
import Accounts
import Social
#else
import SocialAccountKitSwift
#endif // DISABLE_SOCIAL_ACCOUNT_KIT

public typealias TDKTimelineCompletionHandler = (TDKTimeline?, Error?) -> Void
public typealias TDKSearchCompletionHandler = (TDKTimeline?, JSON?, Error?) -> Void
public typealias TDKLookupUserCompletionHandler = ([TDKUser], Error?) -> Void
public typealias TDKRateLimitStatusCompletionHandler = (JSON?, Error?) -> Void

#if DISABLE_SOCIAL_ACCOUNT_KIT
public typealias TDKAccount = ACAccount
#else
public typealias TDKAccount = SAKAccount
#endif // DISABLE_SOCIAL_ACCOUNT_KIT

#if DISABLE_SOCIAL_ACCOUNT_KIT
fileprivate typealias RequestMethod = SLRequestMethod
#else
fileprivate typealias RequestMethod = SAKRequestMethod
#endif // DISABLE_SOCIAL_ACCOUNT_KIT

fileprivate typealias RequestHandler = (Data?, URLResponse?, Error?) -> Void

public class TDKTwitter: NSObject
{
  public internal(set) var account: TDKAccount? = nil

  public required init(account: TDKAccount) {
    super.init()

    self.account = account
  }
}

extension TDKTwitter
{
  fileprivate func connect(to requestURL: URL, method: RequestMethod, parameters: [String:Any], completion: @escaping RequestHandler) -> Void {
    if let account = self.account {
#if DISABLE_SOCIAL_ACCOUNT_KIT
      if let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: method, url: requestURL, parameters: parameters) {
        request.account = account
        request.perform(handler: completion)
      }
#else
      if let request = try? SAKRequest(forAccount: account, requestMethod: method, url: requestURL, parameters: parameters) {
        request.perform(handler: completion)
      }
#endif // DISABLE_SOCIAL_ACCOUNT_KIT
    }
  }
}

// MARK: - Timeline Methods
extension TDKTwitter
{
  public func getHomeTimeline(with parameters: TDKHomeTimelineParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json") {
      let params = parameters?.toJSON() ?? [:]
      self.fetchTimeline(with: requestURL, parameters: params, completion: completion)
    }
  }

  public func getUserTimeline(with parameters: TDKUserTimelineParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json") {
      let params = parameters?.toJSON() ?? [:]
      self.fetchTimeline(with: requestURL, parameters: params, completion: completion)
    }
  }

  func fetchTimeline(with requestURL: URL, parameters: [String:Any], completion: @escaping TDKTimelineCompletionHandler) {
    connect(to: requestURL, method: .GET, parameters: parameters, completion: {
      (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
    })
  }
}

// MARK: - Search Methods
extension TDKTwitter
{
  public func searchTweet(with parameters: TDKSearchTweetParameters? = nil, completion: @escaping TDKSearchCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/search/tweets.json") {
      let params = parameters?.toJSON() ?? [:]
      connect(to: requestURL, method: .GET, parameters: params, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        var metadata: JSON? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json["statuses"])
          metadata = json["search_metadata"]
        }
        completion(timeline, metadata, error)
      })
    }
  }
}

// MARK: - Favorites Methods
extension TDKTwitter
{
  public func getFavoritesList(with parameters: TDKFavoritesParameters? = nil, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/list.json") {
      let params = parameters?.toJSON() ?? [:]
      connect(to: requestURL, method: .GET, parameters: params, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
      })
    }
  }

  public func createFavorites(with statusId: String, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/create.json") {
      let parameters: [String:Any] = [
        "id" : statusId,
        "include_entities" : String(true)
      ]
      connect(to: requestURL, method: .POST, parameters: parameters, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
      })
    }
  }

  public func deleteFavorites(with statusId: String, completion: @escaping TDKTimelineCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/favorites/destroy.json") {
      let parameters: [String:Any] = [
        "id" : statusId,
        "include_entities" : String(true)
      ]
      connect(to: requestURL, method: .POST, parameters: parameters, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
      })
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
      connect(to: requestURL, method: .POST, parameters: parameters, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
      })
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
      connect(to: requestURL, method: .POST, parameters: parameters, completion: {
        (responseData, urlResponse, error) in
        var timeline: TDKTimeline? = nil
        if let jsonData = responseData {
          let json = JSON(jsonData)
          timeline = TDKTimeline(statuses: json)
        }
        completion(timeline, error)
      })
    }
  }
}

// MARK: - Users Methods
extension TDKTwitter
{
  public func lookupUser(with parameters: TDKLookupUserParameters, completion: @escaping TDKLookupUserCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/users/lookup.json") {
      connect(to: requestURL, method: .GET, parameters: parameters.toJSON(), completion: {
        (responseData, urlResponse, error) in
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

  public func showUser(with parameters: TDKLookupUserParameters, completion: @escaping TDKLookupUserCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/users/show.json") {
      connect(to: requestURL, method: .GET, parameters: parameters.toJSON(), completion: {
        (responseData, urlResponse, error) in
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

// MARK: - Rate Limit Status
extension TDKTwitter
{
  public func rateLimitStatus(parameters stringArray: [String] = [], completion: @escaping TDKRateLimitStatusCompletionHandler) {
    if let requestURL = URL(string: "https://api.twitter.com/1.1/application/rate_limit_status.json") {
      let parameters = stringArray.count > 0
                     ? [ "resources": stringArray.joined(separator: ",") ]
                     : Dictionary<String,String>()
      connect(to: requestURL, method: .GET, parameters: parameters, completion: {
        (responseData, urlResponse, error) in
        var json: JSON?
        if let jsonData = responseData {
          json = JSON(jsonData)
        }
        completion(json, error)
      })
    }
  }
}

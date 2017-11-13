/*****************************************************************************
 *
 * FILE:	TDKParameters.swift
 * DESCRIPTION:	TwitterDevKit: REST API Parameters for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Mon, Nov 13 2017
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

public let kDefaultCount: Int = 20

// MARK: - Parameters to fetch timeline
public class TDKTimelineCommonParameters
{
  public internal(set) var count: Int = kDefaultCount

  public var sinceId: Int64 = 0
  public var maxId: Int64 = 0
  public var trimUser: Bool = false
  public var excludeReplies: Bool = false
  public var tweetMode: String = "extended"

  public init(count: Int = kDefaultCount) {
    self.count = (count < 0 ? kDefaultCount : (count > 200 ? 200 : count))
  }

  public func toJSON() -> [String:Any] {
    var json: [String:Any] = [:]
    if count > 0 {
      json["count"] = String(count)
    }
    if sinceId > 0 {
      json["since_id"] = String(sinceId)
    }
    if maxId > 0 {
      json["max_id"] = String(maxId)
    }
    json["trim_user"] = String(trimUser)
    json["exclude_replies"] = String(excludeReplies)
    json["tweet_mode"] = tweetMode
    return json
  }
}

// https://dev.twitter.com/rest/reference/get/statuses/home_timeline
public class TDKHomeTimelineParameters: TDKTimelineCommonParameters
{
  public var includeEntities: Bool = true

  override public func toJSON() -> [String:Any] {
    var json: [String:Any] = super.toJSON()
    json["include_entities"] = String(includeEntities)
    return json
  }
}

// https://dev.twitter.com/rest/reference/get/statuses/user_timeline
public class TDKUserTimelineParameters: TDKTimelineCommonParameters
{
  public internal(set) var userId: Int64 = 0
  public internal(set) var screenName: String? = nil
  public var includeRts: Bool = true

  public init(userId: Int64, count: Int = kDefaultCount) {
    super.init(count: count)
    self.userId = userId
  }

  public init(screenName: String, count: Int = kDefaultCount) {
    super.init(count: count)
    self.screenName = screenName
  }

  override public func toJSON() -> [String:Any] {
    var json: [String:Any] = super.toJSON()
    if userId > 0 {
      json["user_id"] = String(userId)
    }
    if let screenName = screenName {
      json["screen_name"] = screenName
    }
    json["include_rts"] = String(includeRts)
    return json
  }
}

// MARK: - Parameters to search tweet
/*
 * The Search API - Twitter Developers
 *
 * https://dev.twitter.com/rest/reference/get/search/tweets
 *
 * https://dev.twitter.com/rest/public/search
 */
public struct TDKSearchTweetParameters
{
  public internal(set) var count: Int = kDefaultCount

  public var geocode: String? = nil
  public var lang: String? = nil // ISO 639-1 code
  public var locale: String? = nil // only 'ja' is currently effective
  public var resultType: String = "mixed" // 'mixed', 'recent', 'popular'
  public var until: String? = nil // YYYY-MM-DD, 7-day limit
  public var sinceId: Int64 = 0
  public var maxId: Int64 = 0
  public var includeEntities: Bool = true

  public internal(set) var query: String

  public init(q: String, count: Int = kDefaultCount) {
    self.count = (count < 0 ? kDefaultCount : (count > 200 ? 200 : count))
#if DISABLE_SOCIAL_ACCOUNT_KIT
    let filteredQuery = q + " -filter:retweets"
    if let encodedQuery = filteredQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
      self.query = encodedQuery
    }
    else {
      self.query = filteredQuery
    }
#else
    self.query = q + " exclude:retweets"
#endif // DISABLE_SOCIAL_ACCOUNT_KIT
  }

  public func toJSON() -> [String:Any] {
    var json: [String:Any] = [:]
    json["q"] = query
    if count > 0 {
      json["count"] = String(count)
    }
    if let geocode = geocode {
      json["geocode"] = geocode
    }
    if let lang = lang {
      json["lang"] = lang
    }
    if let locale = locale {
      json["locale"] = locale
    }
    json["result_type"] = resultType
    if let until = until {
      json["until"] = until
    }
    if sinceId > 0 {
      json["since_id"] = String(sinceId)
    }
    if maxId > 0 {
      json["max_id"] = String(maxId)
    }
    json["include_entities"] = String(includeEntities)
    return json
  }
}

// MARK: - Parameters to get favorites list
/*
 * https://dev.twitter.com/rest/reference/get/favorites/list
 */
public struct TDKFavoritesParameters
{
  public internal(set) var count: Int = kDefaultCount

  public var userId: Int64 = 0
  public var screenName: String? = nil
  public var sinceId: Int64 = 0
  public var maxId: Int64 = 0
  public var includeEntities: Bool = true

  public init(count: Int = kDefaultCount) {
    self.count = (count < 0 ? kDefaultCount : (count > 200 ? 200 : count))
  }

  public func toJSON() -> [String:Any] {
    var json: [String:Any] = [:]
    if userId > 0 {
      json["user_id"] = String(userId)
    }
    if let screenName = screenName {
      json["screen_name"] = screenName
    }
    if count > 0 {
      json["count"] = String(count)
    }
    if sinceId > 0 {
      json["since_id"] = String(sinceId)
    }
    if maxId > 0 {
      json["max_id"] = String(maxId)
    }
    json["include_entities"] = String(includeEntities)
    return json
  }
}

// MARK: - Parameters to lookup user
/*
 * GET users/lookup - Twitter Developers
 * https://dev.twitter.com/rest/reference/get/users/lookup
 *
 * GET users/show - Twitter Developers
 * https://dev.twitter.com/rest/reference/get/users/show
 */
public struct TDKLookupUserParameters
{
  public internal(set) var userId: Int64 = 0
  public internal(set) var screenName: String? = nil
  public var includeEntities: Bool = true

  public init(screenName: String) {
    self.screenName = screenName
  }

  public init(screenNames: [String]) {
    self.screenName = screenNames.joined(separator: ",")
  }

  public init(userId: Int64) {
    self.userId = userId
  }

  public func toJSON() -> [String:Any] {
    var json: [String:Any] = [:]
    if userId > 0 {
      json["user_id"] = String(userId)
    }
    if let screenName = screenName {
      json["screen_name"] = screenName
    }
    json["include_entities"] = String(includeEntities)
    return json
  }
}

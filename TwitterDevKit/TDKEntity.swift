/*****************************************************************************
 *
 * FILE:	TDKEntity.swift
 * DESCRIPTION:	TwitterDevKit: Defines Classes and Structures for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Thu, Jun 29 2017
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

// https://dev.twitter.com/overview/api/tweets
public struct TDKCoordinates {
  public internal(set) var coordinates: [Double] = [] // [longitude, latitude]
  public internal(set) var type: String = "" // "Point",...

  public init(with type: String, coordinates: [Double]) {
    self.type = type
    self.coordinates = coordinates
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKHashtag {
  public internal(set) var text: String = ""
  public internal(set) var indices: [Int] = []

  public init(with text: String, indices: [Int]) {
    self.text = text
    self.indices = indices
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKSize {
  public internal(set) var w: Int = 0 // Width in pixels
  public internal(set) var h: Int = 0 // Height in pixels
  public internal(set) var resize: String = "fit" // "crop" or "fit"

  public init(with w: Int = 0, h: Int = 0, resize: String = "fit") {
    self.w = w
    self.h = h
    self.resize = resize
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKSizes {
  public internal(set) var  thumb: TDKSize? = nil
  public internal(set) var  large: TDKSize? = nil
  public internal(set) var medium: TDKSize? = nil
  public internal(set) var  small: TDKSize? = nil

  public init(with thumb: TDKSize? = nil, large: TDKSize? = nil, medium: TDKSize? = nil, small: TDKSize? = nil) {
    self.thumb = thumb
    self.large = large
    self.medium = medium
    self.small = small
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKMedia {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil

  public var url: String? = nil
  public var type: String? = nil
  public var sizes: TDKSizes? = nil
  public var displayUrl: String? = nil
  public var expandedUrl: String? = nil
  public var indices: [Int] = []
  public var extAltText: String? = nil
  public var mediaUrl: String? = nil
  public var mediaUrlHttps: String? = nil
  public var sourceStatusId: Int64 = 0
  public var sourceStatusIdStr: String? = nil

  public init(with id: Int64, idStr: String) {
    self.id = id
    self.idStr = idStr
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKURL {
  public internal(set) var url: String? = nil

  public var indices: [Int] = []
  public var displayUrl: String? = nil
  public var expandedUrl: String? = nil

  public init(with url: String) {
    self.url = url
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKUserMention {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var indices: [Int] = []
  public internal(set) var name: String? = nil // display name
  public internal(set) var screenName: String? = nil

  public init(with id: Int64, idStr: String,
              indices: [Int] = [], name: String? = nil, screenName: String? = nil) {
    self.id = id
    self.idStr = idStr
    self.indices = indices
    self.name = name
    self.screenName = screenName
  }
}

public struct TDKSymbol {
  public internal(set) var text: String = ""
  public internal(set) var indices: [Int] = []

  public init(with text: String, indices: [Int]) {
    self.text = text
    self.indices = indices
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKEntities {
  public internal(set) var hashtags: [TDKHashtag] = []
  public internal(set) var media: [TDKMedia] = []
  public internal(set) var urls: [TDKURL] = []
  public internal(set) var userMentions: [TDKUserMention] = []
  public internal(set) var symbols: [TDKSymbol] = []

  public init(with hashtags: [TDKHashtag] = [], media: [TDKMedia] = [], urls: [TDKURL] = [], mentions: [TDKUserMention] = [], symbols: [TDKSymbol] = []) {
    self.hashtags = hashtags
    self.media = media
    self.urls = urls
    self.userMentions = mentions
    self.symbols = symbols
  }
}

public typealias TDKBoundingBoxType = [[[Double]]]

// https://dev.twitter.com/overview/api/places
public struct TDKPlaceBoundingBox {
  public internal(set) var coordinates: TDKBoundingBoxType = []
  public internal(set) var type: String? = nil

  public init(with type: String, coordinates: TDKBoundingBoxType) {
    self.type = type
    self.coordinates = coordinates
  }
}

// https://dev.twitter.com/overview/api/places
public struct TDKPlaceAttribute {
  public internal(set) var twitter: String? = nil

  public var streetAddress: String? = nil
  public var locality: String? = nil
  public var region: String? = nil
  public var iso3: String? = nil
  public var postalCode: String? = nil
  public var phone: String? = nil
  public var url: String? = nil
  public var appId: String? = nil

  public init(with twitter: String) {
    self.twitter = twitter
  }
}

// https://dev.twitter.com/overview/api/places
public struct TDKPlaces {
  public internal(set) var id: String? = nil
  public internal(set) var name: String? = nil

  public var attributes: TDKPlaceAttribute? = nil
  public var boundingBox: TDKPlaceBoundingBox? = nil
  public var country: String? = nil
  public var countryCode: String? = nil
  public var fullName: String? = nil
  public var placeType: String? = nil
  public var url: String? = nil

  public init(with id: String, name: String) {
    self.id = id
    self.name = name
  }
}

public struct TDKDate {
  public internal(set) var dateString: String? = nil
  public internal(set) var date: Date? = nil

  // UTC time like "Wed Aug 27 13:08:45 +0000 2008"
  public init(with dateStr: String) {
    self.dateString = dateStr

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZZ yyyy"
    self.date = dateFormatter.date(from: dateStr)
  }

  public var localizedDateString: String? {
    guard let date = self.date else { return nil }
    return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .medium)
  }
}

// https://dev.twitter.com/overview/api/users
public struct TDKUser {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var createdAt: TDKDate? = nil

  public var name: String? = nil
  public var screenName: String? = nil

  public var contributorsEnabled: Bool = false
  public var defaultProfile: Bool = false
  public var defaultProfileImage: Bool = false
  public var description: String? = nil
  public var entities: TDKUserEntities? = nil
  public var favouritesCount: Int = 0
  public var followRequestSent: Bool = false
  public var following: Bool = false // Deprecated
  public var followersCount: Int = 0
  public var friendsCount: Int = 0
  public var geoEnabled: Bool = false
  public var isTranslator: Bool = false
  public var lang: String? = nil
  public var listedCount: Int = 0
  public var location: String? = nil
  public var notifications: Bool = false
  public var profileBackgroundColor: String? = nil
  public var profileBackgroundImageUrl: String? = nil
  public var profileBackgroundImageUrlHttps: String? = nil
  public var profileBackgroundTile: Bool = false
  public var profileBannerUrl: String? = nil
  public var profileImageUrl: String? = nil
  public var profileImageUrlHttps: String? = nil
  public var profileLinkColor: String? = nil
  public var profileSidebarBorderColor: String? = nil
  public var profileSidebarFillColor: String? = nil
  public var profileTextColor: String? = nil
  public var profileUserBackgroundImage: Bool = false
  public var protected: Bool = false
  public var status: TDKTweet? = nil
  public var statusCount: Int = 0
  public var timeZone: String? = nil
  public var url: String? = nil
  public var utcOffset: Int = 0
  public var verified: Bool = false
  public var withheldInCountries: String? = nil
  public var withheldScope: String? = nil

  public init(with id: Int64, idStr: String, createdAt: String) {
    self.id = id
    self.idStr = idStr
    self.createdAt = TDKDate(with: createdAt)
  }
}

public struct TDKUserEntities {
  public var url: [String:Any] = [:]
  public var description: [String:Any] = [:]
}

// https://dev.twitter.com/overview/api/tweets
public class TDKTweet {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var createdAt: TDKDate? = nil

  public var text: String? = nil
  public var entities: TDKEntities? = nil

  /*
   * Upcoming changes to Tweets ? Twitter Developers
   * https://dev.twitter.com/overview/api/upcoming-changes-to-tweets
   * tweet_mode=extended
   */
  public var fullText: String? = nil
  public var extendedEntities: TDKEntities? = nil
  public var displayTextRange: [Int]? = nil

  public var coordinates: TDKCoordinates? = nil
  public var currentUserRetweet: [String:Any]? = nil
  public var favoriteCount: Int = 0
  public var favorited: Bool = false
  public var inReplyToScreenName: String? = nil
  public var inReplyToStatusId: Int64 = 0
  public var inReplyToStatusIdStr: String? = nil
  public var inReplyToUserId: Int64 = 0
  public var inReplyToUserIdStr: String? = nil
  public var lang: String? = nil
  public var place: TDKPlaces? = nil
  public var possiblySensitive: Bool = false // XXX: "true" なら画像非表示？
  public var quotedStatusId: Int64 = 0
  public var quotedStatusIdStr: String? = nil
  public var quotedStatus: TDKTweet? = nil
  public var scopes: [String:Any]? = nil
  public var retweetCount: Int = 0
  public var retweeted: Bool = false
  public var retweetedStatus: TDKTweet? = nil
  public var source: String? = nil
  public var truncated: Bool = false
  public var user: TDKUser? = nil
  public var withheldCopyright: Bool = false
  public var withheldInCountries: [String]? = nil
  public var withheldScope: String? = nil

  public var jsonData: Data? = nil // オリジナルの生データを保存

  public init(with id: Int64, idStr: String, createdAt: String) {
    self.id = id
    self.idStr = idStr
    self.createdAt = TDKDate(with: createdAt)
  }
}

// MARK: - For Developers
extension TDKTweet
{
  public var prettyPrintedSource: NSAttributedString? {
    return source?.stringWithHTML()
  }

  public func prettyPrintedJSONData() -> String? {
    if let data = jsonData, let dataString = String(data: data, encoding: .utf8) {
      return dataString.replacingOccurrences(of: "\\/", with: "/").replacingOccurrences(of: "\\\"", with: "\"")
    }
    return nil
  }
}


fileprivate extension String
{
  func stringWithHTML() -> NSAttributedString? {
    var attributedString: NSAttributedString? = nil
    if let data = self.data(using: .utf8, allowLossyConversion: true) {
      let options: [String:Any] = [
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: String.Encoding.utf8
      ]
      do {
        attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
      }
      catch {
        // XXX: Nothing to do now...
      }
    }
    return attributedString
  }
}

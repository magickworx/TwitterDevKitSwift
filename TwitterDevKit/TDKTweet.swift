/*****************************************************************************
 *
 * FILE:	TDKTweet.swift
 * DESCRIPTION:	TwitterDevKit: Primitive Tweet Class for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Wed, Sep  6 2017
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

// https://dev.twitter.com/overview/api/tweets
open class TDKTweet {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var createdAt: TDKDate? = nil

  public internal(set) var text: String? = nil
  public internal(set) var entities: TDKEntities? = nil

  /*
   * Upcoming changes to Tweets ? Twitter Developers
   * https://dev.twitter.com/overview/api/upcoming-changes-to-tweets
   * tweet_mode=extended
   */
  public internal(set) var fullText: String? = nil
  public internal(set) var extendedEntities: TDKEntities? = nil
  public internal(set) var displayTextRange: [Int]? = nil

  public internal(set) var coordinates: TDKCoordinates? = nil
  public internal(set) var currentUserRetweet: [String:Any]? = nil
  public internal(set) var favoriteCount: Int = 0
  public internal(set) var favorited: Bool = false
  public internal(set) var inReplyToScreenName: String? = nil
  public internal(set) var inReplyToStatusId: Int64 = 0
  public internal(set) var inReplyToStatusIdStr: String? = nil
  public internal(set) var inReplyToUserId: Int64 = 0
  public internal(set) var inReplyToUserIdStr: String? = nil
  public internal(set) var lang: String? = nil
  public internal(set) var place: TDKPlaces? = nil
  public internal(set) var possiblySensitive: Bool = false // XXX: "true" なら画像非表示？
  public internal(set) var quotedStatusId: Int64 = 0
  public internal(set) var quotedStatusIdStr: String? = nil
  public internal(set) var quotedStatus: TDKTweet? = nil
  public internal(set) var scopes: [String:Any]? = nil
  public internal(set) var retweetCount: Int = 0
  public internal(set) var retweeted: Bool = false
  public internal(set) var retweetedStatus: TDKTweet? = nil
  public internal(set) var source: String? = nil
  public internal(set) var truncated: Bool = false
  public internal(set) var user: TDKUser? = nil
  public internal(set) var withheldCopyright: Bool = false
  public internal(set) var withheldInCountries: [String]? = nil
  public internal(set) var withheldScope: String? = nil

  public internal(set) var jsonData: Data? = nil // オリジナルの生データを保存

  public init(_ json: JSON) {
    if let id = json["id"].int64 {
      self.id = id
    }
    if let idStr = json["id_str"].string {
      self.idStr = idStr
    }
    if let createdAt = json["created_at"].string {
      self.createdAt = TDKDate(with: createdAt)
    }
    if let text = json["text"].string {
      self.text = text
    }

    if let jsonData = json.data {
      self.jsonData = jsonData
    }

    if json["coordinates"].dictionary != nil {
      self.coordinates = TDKCoordinates(json["coordinates"])
    }
    if let dval = json["current_user_retweet"].dictionary {
      self.currentUserRetweet = dval as [String:Any]
    }
    if json["entities"].dictionary != nil {
      self.entities = TDKEntities(json["entities"])
    }

    if let text = json["full_text"].string {
      self.fullText = text
    }
    if json["extended_entities"].dictionary != nil {
      self.extendedEntities = TDKEntities(json["extended_entities"])
    }
    if let aval = json["display_text_range"].array {
      self.displayTextRange = aval as? [Int]
    }

    if let nval = json["favorite_count"].int {
      self.favoriteCount = nval
    }
    if let bval = json["favorited"].bool {
      self.favorited = bval
    }
    if let sval = json["in_reply_to_screen_name"].string {
      self.inReplyToScreenName = sval
    }
    if let ival = json["in_reply_to_status_id"].int64 {
      self.inReplyToStatusId = ival
    }
    if let sval = json["in_reply_to_status_id_str"].string {
      self.inReplyToStatusIdStr = sval
    }
    if let ival = json["in_reply_to_user_id"].int64 {
      self.inReplyToUserId = ival
    }
    if let sval = json["in_reply_to_user_id_str"].string {
      self.inReplyToUserIdStr = sval
    }
    if let sval = json["lang"].string {
      self.lang = sval
    }
    if json["place"].dictionary != nil {
      self.place = TDKPlaces(json["place"])
    }
    if let bval = json["possibly_sensitive"].bool {
      self.possiblySensitive = bval
    }
    if let ival = json["quoted_status_id"].int64 {
      self.quotedStatusId = ival
    }
    if let sval = json["quoted_status_id_str"].string {
      self.quotedStatusIdStr = sval
    }
    if json["quoted_status"].dictionary != nil {
      self.quotedStatus = TDKTweet(json["quoted_status"])
    }
    if let dval = json["scopes"].dictionary {
      self.scopes = dval as [String:Any]
    }
    if let ival = json["retweet_count"].int {
      self.retweetCount = ival
    }
    if let bval = json["retweeted"].bool {
      self.retweeted = bval
    }
    if json["retweeted_status"].dictionary != nil {
      self.retweetedStatus = TDKTweet(json["retweeted_status"])
    }
    if let sval = json["source"].string {
      self.source = sval
    }
    if let bval = json["truncated"].bool {
      self.truncated = bval
    }
    if json["user"].dictionary != nil {
      self.user = TDKUser(json["user"])
    }
    if let bval = json["withheld_copyright"].bool {
      self.withheldCopyright = bval
    }
    if let aval = json["withheld_in_countries"].array {
      self.withheldInCountries = aval as? [String]
    }
    if let sval = json["withheld_scope"].string {
      self.withheldScope = sval
    }
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

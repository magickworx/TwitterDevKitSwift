/*****************************************************************************
 *
 * FILE:	TDKParser.swift
 * DESCRIPTION:	TwitterDevKit: Twitter API Response Parser
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Thu, Jun 22 2017
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

extension TDKTimeline {
  func parseStatus(_ json: JSON) -> TDKTweet? {
    if let    id = json["id"].int64,
       let idStr = json["id_str"].string,
       let  date = json["created_at"].string {
      let tweet = TDKTweet(with: id, idStr: idStr, createdAt: date)
      if let text = json["text"].string {
        tweet.text = text
      }
      if json["coordinates"].dictionary != nil {
        if let coordinates = self.parseCoordinates(json["coordinates"]) {
          tweet.coordinates = coordinates
        }
      }
      if let dval = json["current_user_retweet"].dictionary {
        tweet.currentUserRetweet = dval as [String:Any]
      }
      if json["entities"].dictionary != nil {
        tweet.entities = self.parseEntities(json["entities"])
      }
      if let nval = json["favorite_count"].int {
        tweet.favoriteCount = nval
      }
      if let bval = json["favorited"].bool {
        tweet.favorited = bval
      }
      if let sval = json["filterLevel"].string {
        tweet.filterLevel = sval
      }
      if let sval = json["in_reply_to_screen_name"].string {
        tweet.inReplyToScreenName = sval
      }
      if let ival = json["in_reply_to_status_id"].int64 {
        tweet.inReplyToStatusId = ival
      }
      if let sval = json["in_reply_to_status_id_str"].string {
        tweet.inReplyToStatusIdStr = sval
      }
      if let ival = json["in_reply_to_user_id"].int64 {
        tweet.inReplyToUserId = ival
      }
      if let sval = json["in_reply_to_user_id_str"].string {
        tweet.inReplyToUserIdStr = sval
      }
      if let sval = json["lang"].string {
        tweet.lang = sval
      }
      if json["place"].dictionary != nil {
        if let place = self.parsePlace(json["place"]) {
          tweet.place = place
        }
      }
      if let bval = json["possibly_sensitive"].bool {
        tweet.possiblySensitive = bval
      }
      if let ival = json["quoted_status_id"].int64 {
        tweet.quotedStatusId = ival
      }
      if let sval = json["quoted_status_id_str"].string {
        tweet.quotedStatusIdStr = sval
      }
      if json["quoted_status"].dictionary != nil {
        if let status = self.parseStatus(json["quoted_status"]) {
          tweet.quotedStatus = status
        }
      }
      if let dval = json["scopes"].dictionary {
        tweet.scopes = dval as [String:Any]
      }
      if let ival = json["retweet_count"].int {
        tweet.retweetCount = ival
      }
      if let bval = json["retweeted"].bool {
        tweet.retweeted = bval
      }
      if json["retweeted_status"].dictionary != nil {
        if let status = self.parseStatus(json["retweeted_status"]) {
          tweet.retweetedStatus = status
        }
      }
      if let sval = json["source"].string {
        tweet.source = sval
      }
      if let bval = json["truncated"].bool {
        tweet.truncated = bval
      }
      if json["user"].dictionary != nil {
        if let user = self.parseUser(json["user"]) {
          tweet.user = user
        }
      }
      if let bval = json["withheld_copyright"].bool {
        tweet.withheldCopyright = bval
      }
      if let aval = json["withheld_in_countries"].array {
        tweet.withheldInCountries = aval as? [String]
      }
      if let sval = json["withheld_scope"].string {
        tweet.withheldScope = sval
      }
      return tweet
    }
    return nil
  }
}

extension TDKTimeline {
  func parseEntities(_ json: JSON) -> TDKEntities {
    var hashtags: [TDKHashtag] = []
    var media: [TDKMedia] = []
    var urls: [TDKURL] = []
    var mentions: [TDKUserMention] = []
    var symbols: [TDKSymbol] = []

    if json["hashtags"].array != nil {
      hashtags = self.parseHashtags(json["hashtags"])
    }
    if json["media"].array != nil {
      media = self.parseMedia(json["media"])
    }
    if json["urls"].array != nil {
      urls = self.parseURLs(json["urls"])
    }
    if json["user_mentions"].array != nil {
      mentions = self.parseMentions(json["user_mentions"])
    }
    if json["symbols"].array != nil {
      symbols = self.parseSymbols(json["symbols"])
    }

    return TDKEntities(with: hashtags, media: media, urls: urls, mentions: mentions, symbols: symbols)
  }

  func parseHashtags(_ json: JSON) -> [TDKHashtag] {
    var contents: [TDKHashtag] = []
    for entity in json {
      if let    text = entity["text"].string,
         let indices = entity["indices"].array as? [Int] {
        contents.append(TDKHashtag(with: text, indices: indices))
      }
    }
    return contents
  }

  func parseMedia(_ json: JSON) -> [TDKMedia] {
    var contents: [TDKMedia] = []
    for entity in json {
      if let    id = entity["id"].int64,
         let idStr = entity["id_str"].string {
        var media = TDKMedia(with: id, idStr: idStr)
        if let url = entity["url"].string {
          media.url = url
        }
        if let type = entity["type"].string {
          media.type = type
        }
        if entity["sizes"].dictionary != nil {
          media.sizes = self.parseSizes(entity["sizes"])
        }
        if let indices = entity["indices"].array as? [Int] {
          media.indices = indices
        }
        if let sval = entity["display_url"].string {
          media.displayUrl = sval
        }
        if let sval = entity["expanded_url"].string {
          media.expandedUrl = sval
        }
        if let sval = entity["ext_alt_text"].string {
          media.extAltText = sval
        }
        if let sval = entity["media_url"].string {
          media.mediaUrl = sval
        }
        if let sval = entity["media_url_https"].string {
          media.mediaUrlHttps = sval
        }
        if let ival = entity["source_status_id"].int64 {
          media.sourceStatusId = ival
        }
        if let sval = entity["source_status_id_str"].string {
          media.sourceStatusIdStr = sval
        }
        contents.append(media)
      }
    }
    return contents
  }

  func parseSizes(_ json: JSON) -> TDKSizes {
    var large: TDKSize? = nil
    if json["large"].dictionary != nil {
      large = self.parseSize(json["large"])
    }
    var medium: TDKSize? = nil
    if json["medium"].dictionary != nil {
      medium = self.parseSize(json["medium"])
    }
    var small: TDKSize? = nil
    if json["small"].dictionary != nil {
      small = self.parseSize(json["small"])
    }
    var thumb: TDKSize? = nil
    if json["thumb"].dictionary != nil {
      thumb = self.parseSize(json["thumb"])
    }
    return TDKSizes(with: thumb, large: large, medium: medium, small: small)
  }

  func parseSize(_ json: JSON) -> TDKSize {
    if let w = json["w"].int, let h = json["h"].int,
       let resize = json["resize"].string {
      return TDKSize(with: w, h: h, resize: resize)
    }
    return TDKSize()
  }

  func parseURLs(_ json: JSON) -> [TDKURL] {
    var contents: [TDKURL] = []
    for entity in json {
      if let urlStr = entity["url"].string {
        var url: TDKURL = TDKURL(with: urlStr)
        if let aval = entity["indices"].array as? [Int] {
          url.indices = aval
        }
        if let sval = entity["display_url"].string {
          url.displayUrl = sval
        }
        if let sval = entity["expanded_url"].string {
          url.expandedUrl = sval
        }
        contents.append(url)
      }
    }
    return contents
  }

  func parseMentions(_ json: JSON) -> [TDKUserMention] {
    var contents: [TDKUserMention] = []
    for entity in json {
      if let      id = entity["id"].int64,
         let   idStr = entity["id_str"].string,
         let    name = entity["name"].string,
         let  screen = entity["screen_name"].string {
        var indices: [Int] = []
        if let aval = entity["indices"].array as? [Int] {
          indices = aval
        }
        contents.append(TDKUserMention(with: id, idStr: idStr, indices: indices, name: name, screenName: screen))
      }
    }
    return contents
  }

  func parseSymbols(_ json: JSON) -> [TDKSymbol] {
    var contents: [TDKSymbol] = []
    for entity in json {
      if let    text = entity["text"].string,
         let indices = entity["indices"].array as? [Int] {
        contents.append(TDKSymbol(with: text, indices: indices))
      }
    }
    return contents
  }
}

extension TDKTimeline {
  func parseUser(_ json: JSON) -> TDKUser? {
    if let     id = json["id"].int64,
       let  idStr = json["id_str"].string,
       let   date = json["created_at"].string {
      var user = TDKUser(with: id, idStr: idStr, createdAt: date)
      if let name = json["name"].string {
        user.name = name
      }
      if let screenName = json["screen_name"].string {
        user.screenName = screenName
      }
      if let bval = json["contributors_enabled"].bool {
        user.contributorsEnabled = bval
      }
      if let bval = json["default_profile"].bool {
        user.defaultProfile = bval
      }
      if let bval = json["default_profile_image"].bool {
        user.defaultProfileImage = bval
      }
      if let sval = json["description"].string {
        user.description = sval
      }
      if json["entities"].dictionary != nil {
        user.entities = self.parseUserEntities(json["entities"])
      }
      if let ival = json["favourites_count"].int {
        user.favouritesCount = ival
      }
      if let bval = json["follow_request_sent"].bool {
        user.followRequestSent = bval
      }
      if let ival = json["followers_count"].int {
        user.followersCount = ival
      }
      if let bval = json["following"].bool {
        user.following = bval
      }
      if let ival = json["friends_count"].int {
        user.friendsCount = ival
      }
      if let bval = json["geo_enabled"].bool {
        user.geoEnabled = bval
      }
      if let bval = json["is_translator"].bool {
        user.isTranslator = bval
      }
      if let sval = json["lang"].string {
        user.lang = sval
      }
      if let ival = json["listed_count"].int {
        user.listedCount = ival
      }
      if let sval = json["location"].string {
        user.location = sval
      }
      if let bval = json["notifications"].bool {
        user.notifications = bval
      }
      if let sval = json["profile_background_color"].string {
        user.profileBackgroundColor = sval
      }
      if let sval = json["profile_background_image_url"].string {
        user.profileBackgroundImageUrl = sval
      }
      if let sval = json["profile_background_image_url_https"].string {
        user.profileBackgroundImageUrlHttps = sval
      }
      if let bval = json["profile_background_tile"].bool {
        user.profileBackgroundTile = bval
      }
      if let sval = json["profile_banner_url"].string {
        user.profileBannerUrl = sval
      }
      if let sval = json["profile_image_url"].string {
        user.profileImageUrl = sval
      }
      if let sval = json["profile_image_url_https"].string {
        user.profileImageUrlHttps = sval
      }
      if let sval = json["profile_link_color"].string {
        user.profileLinkColor = sval
      }
      if let sval = json["profile_sidebar_border_color"].string {
        user.profileSidebarBorderColor = sval
      }
      if let sval = json["profile_sidebar_fill_color"].string {
        user.profileSidebarFillColor = sval
      }
      if let sval = json["profile_text_color"].string {
        user.profileTextColor = sval
      }
      if let bval = json["profile_user_background_image"].bool {
        user.profileUserBackgroundImage = bval
      }
      if let bval = json["protected"].bool {
        user.protected = bval
      }
      if json["status"].dictionary != nil {
        if let status = self.parseStatus(json["status"]) {
          user.status = status
        }
      }
      if let ival = json["status_count"].int {
        user.statusCount = ival
      }
      if let sval = json["time_zone"].string {
        user.timeZone = sval
      }
      if let sval = json["url"].string {
        user.url = sval
      }
      if let ival = json["utc_offset"].int {
        user.utcOffset = ival
      }
      if let bval = json["verified"].bool {
        user.verified = bval
      }
      if let sval = json["withheld_in_countries"].string {
        user.withheldInCountries = sval
      }
      if let sval = json["withheld_scope"].string {
        user.withheldScope = sval
      }
      return user
    }
    return nil
  }

  func parseUserEntities(_ json: JSON) -> TDKUserEntities {
    var entities = TDKUserEntities()
    if json["url"].dictionary != nil {
      let urls: [TDKURL] = parseURLs(json["url"]["urls"])
      entities.url = [ "urls" : urls ]
    }
    if json["description"].dictionary != nil {
      let urls: [TDKURL] = parseURLs(json["description"]["urls"])
      entities.description = [ "urls" : urls ]
    }
    return entities
  }
}

extension TDKTimeline {
  func parseCoordinates(_ json: JSON) -> TDKCoordinates? {
    if let  type = json["type"].string,
       let coord = json["coordinates"].array as? [Double] {
      return TDKCoordinates(with: type, coordinates: coord)
    }
    return nil
  }

  func parsePlaceAttributes(_ json: JSON) -> TDKPlaceAttribute? {
    if let twitter = json["twitter"].string {
      var attr = TDKPlaceAttribute(with: twitter)

      if let sval = json["street_address"].string {
        attr.streetAddress = sval
      }
      if let sval = json["locality"].string {
        attr.locality = sval
      }
      if let sval = json["region"].string {
        attr.region = sval
      }
      if let sval = json["iso3"].string {
        attr.iso3 = sval
      }
      if let sval = json["postal_code"].string {
        attr.postalCode = sval
      }
      if let sval = json["phone"].string {
        attr.phone = sval
      }
      if let sval = json["url"].string {
        attr.url = sval
      }
      if let sval = json["appId"].string {
        attr.appId = sval
      }
      return attr
    }
    return nil
  }

  func parsePlaceBoundingBox(_ json: JSON) -> TDKPlaceBoundingBox? {
    if let type = json["type"].string, let coord = json["coordinates"].array as? TDKBoundingBoxType {
      return TDKPlaceBoundingBox(with: type, coordinates: coord)
    }
    return nil
  }

  func parsePlace(_ json: JSON) -> TDKPlaces? {
    if let   id = json["id"].string,
       let name = json["name"].string {
      var place = TDKPlaces(with: id, name: name)

      if json["attributes"].dictionary != nil {
        if let attributes = self.parsePlaceAttributes(json["attributes"]) {
          place.attributes = attributes
        }
      }
      if json["bounding_box"].dictionary != nil {
        if let boundingBox = self.parsePlaceBoundingBox(json["bounding_box"]) {
          place.boundingBox = boundingBox
        }
      }
      if let sval = json["country"].string {
        place.country = sval
      }
      if let sval = json["country_code"].string {
        place.countryCode = sval
      }
      if let sval = json["full_name"].string {
        place.fullName = sval
      }
      if let sval = json["place_type"].string {
        place.placeType = sval
      }
      if let sval = json["url"].string {
        place.url = sval
      }
      return place
    }
    return nil
  }
}

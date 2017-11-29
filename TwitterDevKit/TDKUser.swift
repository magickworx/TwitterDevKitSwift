/*****************************************************************************
 *
 * FILE:	TDKUser.swift
 * DESCRIPTION:	TwitterDevKit: User Structure for Entity of Twitter
 * DATE:	Sat, Jun 10 2017
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
 * $Id$
 *
 *****************************************************************************/

import Foundation
import UIKit

// https://dev.twitter.com/overview/api/users
public class TDKUser
{
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var createdAt: TDKDate? = nil

  public internal(set) var name: String? = nil
  public internal(set) var screenName: String? = nil

  public internal(set) var contributorsEnabled: Bool = false
  public internal(set) var defaultProfile: Bool = false
  public internal(set) var defaultProfileImage: Bool = false
  public internal(set) var description: String? = nil
  public internal(set) var entities: TDKUserEntities? = nil
  public internal(set) var favouritesCount: Int = 0
  public internal(set) var followRequestSent: Bool = false
  public internal(set) var following: Bool = false // Deprecated
  public internal(set) var followersCount: Int = 0
  public internal(set) var friendsCount: Int = 0
  public internal(set) var geoEnabled: Bool = false
  public internal(set) var isTranslator: Bool = false
  public internal(set) var lang: String? = nil
  public internal(set) var listedCount: Int = 0
  public internal(set) var location: String? = nil
  public internal(set) var notifications: Bool = false
  public internal(set) var profileBackgroundColor: String? = nil
  public internal(set) var profileBackgroundImageUrl: String? = nil
  public internal(set) var profileBackgroundImageUrlHttps: String? = nil
  public internal(set) var profileBackgroundTile: Bool = false
  public internal(set) var profileBannerUrl: String? = nil
  public internal(set) var profileImageUrl: String? = nil
  public internal(set) var profileImageUrlHttps: String? = nil
  public internal(set) var profileLinkColor: String? = nil
  public internal(set) var profileSidebarBorderColor: String? = nil
  public internal(set) var profileSidebarFillColor: String? = nil
  public internal(set) var profileTextColor: String? = nil
  public internal(set) var profileUserBackgroundImage: Bool = false
  public internal(set) var protected: Bool = false
  public internal(set) var status: TDKTweet? = nil
  public internal(set) var statusCount: Int = 0
  public internal(set) var timeZone: String? = nil
  public internal(set) var url: String? = nil
  public internal(set) var utcOffset: Int = 0
  public internal(set) var verified: Bool = false
  public internal(set) var withheldInCountries: String? = nil
  public internal(set) var withheldScope: String? = nil

  public init(_ json: JSON) {
    if let id = json["id"].int64 {
      self.id = id
    }
    if let idStr = json["id_str"].string {
      self.idStr = idStr
    }
    if let createdAt = json["created_at"].string {
      self.createdAt = TDKDate(string: createdAt)
    }

    if let name = json["name"].string {
      self.name = name
    }
    if let screenName = json["screen_name"].string {
      self.screenName = screenName
    }
    if let bval = json["contributors_enabled"].bool {
      self.contributorsEnabled = bval
    }
    if let bval = json["default_profile"].bool {
      self.defaultProfile = bval
    }
    if let bval = json["default_profile_image"].bool {
      self.defaultProfileImage = bval
    }
    if let sval = json["description"].string {
      self.description = sval
    }
    if json["entities"].dictionary != nil {
      self.entities = TDKUserEntities(json["entities"])
    }
    if let ival = json["favourites_count"].int {
      self.favouritesCount = ival
    }
    if let bval = json["follow_request_sent"].bool {
      self.followRequestSent = bval
    }
    if let ival = json["followers_count"].int {
      self.followersCount = ival
    }
    if let bval = json["following"].bool {
      self.following = bval
    }
    if let ival = json["friends_count"].int {
      self.friendsCount = ival
    }
    if let bval = json["geo_enabled"].bool {
      self.geoEnabled = bval
    }
    if let bval = json["is_translator"].bool {
      self.isTranslator = bval
    }
    if let sval = json["lang"].string {
      self.lang = sval
    }
    if let ival = json["listed_count"].int {
      self.listedCount = ival
    }
    if let sval = json["location"].string {
      self.location = sval
    }
    if let bval = json["notifications"].bool {
      self.notifications = bval
    }
    if let sval = json["profile_background_color"].string {
      self.profileBackgroundColor = sval
    }
    if let sval = json["profile_background_image_url"].string {
      self.profileBackgroundImageUrl = sval
    }
    if let sval = json["profile_background_image_url_https"].string {
      self.profileBackgroundImageUrlHttps = sval
    }
    if let bval = json["profile_background_tile"].bool {
      self.profileBackgroundTile = bval
    }
    if let sval = json["profile_banner_url"].string {
      self.profileBannerUrl = sval
    }
    if let sval = json["profile_image_url"].string {
      self.profileImageUrl = sval
    }
    if let sval = json["profile_image_url_https"].string {
      self.profileImageUrlHttps = sval
    }
    if let sval = json["profile_link_color"].string {
      self.profileLinkColor = sval
    }
    if let sval = json["profile_sidebar_border_color"].string {
      self.profileSidebarBorderColor = sval
    }
    if let sval = json["profile_sidebar_fill_color"].string {
      self.profileSidebarFillColor = sval
    }
    if let sval = json["profile_text_color"].string {
      self.profileTextColor = sval
    }
    if let bval = json["profile_user_background_image"].bool {
      self.profileUserBackgroundImage = bval
    }
    if let bval = json["protected"].bool {
      self.protected = bval
    }
    if json["status"].dictionary != nil {
      self.status = TDKTweet(json["status"])
    }
    if let ival = json["status_count"].int {
      self.statusCount = ival
    }
    if let sval = json["time_zone"].string {
      self.timeZone = sval
    }
    if let sval = json["url"].string {
      self.url = sval
    }
    if let ival = json["utc_offset"].int {
      self.utcOffset = ival
    }
    if let bval = json["verified"].bool {
      self.verified = bval
    }
    if let sval = json["withheld_in_countries"].string {
      self.withheldInCountries = sval
    }
    if let sval = json["withheld_scope"].string {
      self.withheldScope = sval
    }
  }

  public static let profileImageSize: CGFloat = 48.0
}

// MARK: - Convenience Methods for Clients
extension TDKUser
{
  public func fetchProfileImage(with size: CGSize = CGSize(width: TDKUser.profileImageSize, height: TDKUser.profileImageSize), imageSize: ProfileImageSize = .custom, completion: @escaping TDKImageCacheLoaderCompletionHandler) {
    var urlString: String = ""
    if let url = self.profileImageUrlHttps {
      urlString = imageSize.convert(from: url)
    }
    else if let url = self.profileImageUrl {
      urlString = imageSize.convert(from: url)
    }
    else {
      completion(nil, nil)
    }
    TDKImageCacheLoader.shared.fetchImage(with: urlString, resized: size, completion: completion)
  }
}

public struct TDKUserEntities
{
  public internal(set) var url: [String:Any] = [:]
  public internal(set) var description: [String:Any] = [:]

  public init(_ json: JSON) {
    if json["url"].dictionary != nil {
      let urls: [TDKURL] = parseURLs(json["url"]["urls"])
      self.url = [ "urls" : urls ]
    }
    if json["description"].dictionary != nil {
      let urls: [TDKURL] = parseURLs(json["description"]["urls"])
      self.description = [ "urls" : urls ]
    }
  }

  func parseURLs(_ json: JSON) -> [TDKURL] {
    var contents: [TDKURL] = []
    for entity in json {
      contents.append(TDKURL(entity))
    }
    return contents
  }
}

public enum ProfileImageSize
{
  case original
  case normal // 48x48 [px]
  case bigger // 73x73 [px]
  case mini   // 24x24 [px]
  case custom // 400x400? [px] (undocumented)

  public func convert(from urlString: String) -> String {
    var suffix: String = ""
    switch self {
      case .normal:
        suffix = "_normal"
      case .bigger:
        suffix = "_bigger"
      case .mini:
        suffix = "_mini"
      case .original:
        suffix = ""
      case .custom:
        suffix = "_400x400"
    }
    return urlString.replacingOccurrences(of: "_normal", with: suffix)
  }
}

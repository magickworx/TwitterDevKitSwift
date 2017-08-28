/*****************************************************************************
 *
 * FILE:	TDKEntities.swift
 * DESCRIPTION:	TwitterDevKit: Entities Structures for Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Tue, Aug 22 2017
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

// https://dev.twitter.com/overview/api/entities
public struct TDKHashtag {
  public internal(set) var text: String = ""
  public internal(set) var indices: [Int] = []

  public init(_ json: JSON) {
    if let text = json["text"].string {
      self.text = text
    }
    if let indices = json["indices"].array as? [Int] {
      self.indices = indices
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKSize {
  public internal(set) var w: Int = 0 // Width in pixels
  public internal(set) var h: Int = 0 // Height in pixels
  public internal(set) var resize: String = "fit" // "crop" or "fit"

  public init(_ json: JSON) {
    if let w = json["w"].int {
      self.w = w
    }
    if let h = json["h"].int {
      self.h = h
    }
    if let resize = json["resize"].string {
      self.resize = resize
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKSizes {
  public internal(set) var  thumb: TDKSize? = nil
  public internal(set) var  large: TDKSize? = nil
  public internal(set) var medium: TDKSize? = nil
  public internal(set) var  small: TDKSize? = nil

  public init(_ json: JSON) {
    if json["thumb"].dictionary != nil {
      self.thumb = TDKSize(json["thumb"])
    }
    if json["large"].dictionary != nil {
      self.large = TDKSize(json["large"])
    }
    if json["medium"].dictionary != nil {
      self.medium = TDKSize(json["medium"])
    }
    if json["small"].dictionary != nil {
      self.small = TDKSize(json["small"])
    }
  }
}

// https://dev.twitter.com/overview/api/entities-in-twitter-objects
public struct TDKVariant {
  public internal(set) var bitrate: Int = 0
  public internal(set) var contentType: String? = nil
  public internal(set) var url: String? = nil

  public init(_ json: JSON) {
    if let bitrate = json["bitrate"].int {
      self.bitrate = bitrate
    }
    if let type = json["content_type"].string {
      self.contentType = type
    }
    if let url = json["url"].string {
      self.url = url
    }
  }
}

// https://dev.twitter.com/overview/api/entities-in-twitter-objects
public struct TDKVideoInfo {
  public internal(set) var aspectRatio: [Int] = []
  public internal(set) var durationMillis: Int = 0
  public internal(set) var variants: [TDKVariant] = []

  public init(_ json: JSON) {
    if let ratio = json["aspect_ratio"].array as? [Int] {
      self.aspectRatio = ratio
    }
    if let duration = json["duration_millis"].int {
      self.durationMillis = duration
    }
    if json["variants"].array != nil {
      let array = json["variants"]
      var contents: [TDKVariant] = []
      for item in array {
        contents.append(TDKVariant(item))
      }
      self.variants = contents
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKMedia {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil

  public internal(set) var url: String? = nil
  public internal(set) var type: String? = nil
  public internal(set) var sizes: TDKSizes? = nil
  public internal(set) var displayUrl: String? = nil
  public internal(set) var expandedUrl: String? = nil
  public internal(set) var indices: [Int] = []
  public internal(set) var extAltText: String? = nil
  public internal(set) var mediaUrl: String? = nil
  public internal(set) var mediaUrlHttps: String? = nil
  public internal(set) var sourceStatusId: Int64 = 0
  public internal(set) var sourceStatusIdStr: String? = nil
  // XXX: extended_entities are as follows.
  public internal(set) var videoInfo: TDKVideoInfo? = nil

  public init(_ json: JSON) {
    if let id = json["id"].int64 {
      self.id = id
    }
    if let idStr = json["id_str"].string {
      self.idStr = idStr
    }

    if let url = json["url"].string {
      self.url = url
    }
    if let type = json["type"].string {
      self.type = type
    }
    if json["sizes"].dictionary != nil {
      self.sizes = TDKSizes(json["sizes"])
    }
    if let indices = json["indices"].array as? [Int] {
      self.indices = indices
    }
    if let sval = json["display_url"].string {
      self.displayUrl = sval
    }
    if let sval = json["expanded_url"].string {
      self.expandedUrl = sval
    }
    if let sval = json["ext_alt_text"].string {
      self.extAltText = sval
    }
    if let sval = json["media_url"].string {
      self.mediaUrl = sval
    }
    if let sval = json["media_url_https"].string {
      self.mediaUrlHttps = sval
    }
    if let ival = json["source_status_id"].int64 {
      self.sourceStatusId = ival
    }
    if let sval = json["source_status_id_str"].string {
      self.sourceStatusIdStr = sval
    }

    // XXX: extended_entities are as follows.
    if json["video_info"].dictionary != nil {
      self.videoInfo = TDKVideoInfo(json["video_info"])
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKURL {
  public internal(set) var url: String? = nil

  public internal(set) var indices: [Int] = []
  public internal(set) var displayUrl: String? = nil
  public internal(set) var expandedUrl: String? = nil

  public init(_ json: JSON) {
    if let url = json["url"].string {
      self.url = url
    }

    if let aval = json["indices"].array as? [Int] {
      self.indices = aval
    }
    if let sval = json["display_url"].string {
      self.displayUrl = sval
    }
    if let sval = json["expanded_url"].string {
      self.expandedUrl = sval
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKUserMention {
  public internal(set) var id: Int64 = 0
  public internal(set) var idStr: String? = nil
  public internal(set) var indices: [Int] = []
  public internal(set) var name: String? = nil // display name
  public internal(set) var screenName: String? = nil

  public init(_ json: JSON) {
    if let id = json["id"].int64 {
      self.id = id
    }
    if let idStr = json["id_str"].string {
      self.idStr = idStr
    }
    if let name = json["name"].string {
      self.name = name
    }
    if let screenName = json["screen_name"].string {
      self.screenName = screenName
    }
    if let indices = json["indices"].array as? [Int] {
      self.indices = indices
    }
  }
}

public struct TDKSymbol {
  public internal(set) var text: String = ""
  public internal(set) var indices: [Int] = []

  public init(_ json: JSON) {
    if let text = json["text"].string {
      self.text = text
    }
    if let indices = json["indices"].array as? [Int] {
      self.indices = indices
    }
  }
}

// https://dev.twitter.com/overview/api/entities
public struct TDKEntities {
  public internal(set) var hashtags: [TDKHashtag] = []
  public internal(set) var media: [TDKMedia] = []
  public internal(set) var urls: [TDKURL] = []
  public internal(set) var userMentions: [TDKUserMention] = []
  public internal(set) var symbols: [TDKSymbol] = []

  public init(_ json: JSON) {
    if json["hashtags"].array != nil {
      let array = json["hashtags"]
      var contents: [TDKHashtag] = []
      for item in array {
        contents.append(TDKHashtag(item))
      }
      self.hashtags = contents
    }
    if json["media"].array != nil {
      let array = json["media"]
      var contents: [TDKMedia] = []
      for item in array {
        contents.append(TDKMedia(item))
      }
      self.media = contents
    }
    if json["urls"].array != nil {
      let array = json["urls"]
      var contents: [TDKURL] = []
      for item in array {
        contents.append(TDKURL(item))
      }
      self.urls = contents
    }
    if json["user_mentions"].array != nil {
      let array = json["user_mentions"]
      var contents: [TDKUserMention] = []
      for item in array {
        contents.append(TDKUserMention(item))
      }
      self.userMentions = contents
    }
    if json["symbols"].array != nil {
      let array = json["symbols"]
      var contents: [TDKSymbol] = []
      for item in array {
        contents.append(TDKSymbol(item))
      }
      self.symbols = contents
    }
  }
}

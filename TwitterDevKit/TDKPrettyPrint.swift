/*****************************************************************************
 *
 * FILE:	TDKPrettyPrint.swift
 * DESCRIPTION:	TwitterDevKit: Pretty Formatter for Tweet
 * DATE:	Wed, Jun 14 2017
 * UPDATED:	Tue, Jun 20 2017
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

/*
 * NSMutableAttributedString の attributes 設定用
 * 以下のキーに attributes を設定する
 */
public enum TDKTweetAttribute: String {
  case   tweet = "tweet"
  case hashtag = "hashtag"
  case   media = "media"
  case     url = "url"
  case mention = "mention"
}

/*
 * XXX: 2017/06/14 (Wed)
 * 絵文字を含む文字列では addAttributes() の範囲が期待通りに機能しない。
 *
 * ios - End of NSAttributedString with emojis left unformatted
 *     - Stack Overflow
 *       https://stackoverflow.com/questions/31081213/end-of-nsattributedstring-with-emojis-left-unformatted
 */

// MARK: - Properties
extension TDKTweet
{
  public var prettyPrint: NSAttributedString? {
    guard let tweet = text else {
      return nil
    }
    let tweetString = NSMutableAttributedString(string: tweet)
    tweetString.addAttributes([
      NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)
    ], range: NSRange(location: 0, length: tweetString.length))

    if let hashtags = entities?.hashtags {
      let attributes: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14.0),
        NSForegroundColorAttributeName : UIColor.brown
      ]
      for hashtag in hashtags {
        if let range = tweet.range(of: "#" + hashtag.text) {
          tweetString.addAttributes(attributes, range: tweet.nsRange(from: range))
        }
        else
        if let start = hashtag.indices.first,
           let   end = hashtag.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(attributes, range: range)
        }
      }
    }

    if let media = entities?.media {
      let attributes: [String:Any] = [
        NSForegroundColorAttributeName : UIColor.cyan,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      for medium in media {
        if let start = medium.indices.first,
           let   end = medium.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(attributes, range: range)
        }
      }
    }

    if let urls = entities?.urls {
      let attributes: [String:Any] = [
        NSForegroundColorAttributeName : UIColor.blue,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      for url in urls {
        if let start = url.indices.first,
           let   end = url.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(attributes, range: range)
        }
        else if let urlStr = url.url {
          if let range = tweet.range(of: urlStr) {
            tweetString.addAttributes(attributes, range: tweet.nsRange(from: range))
          }
        }
      }
    }

    if let mentions = entities?.userMentions {
      let attributes = [ NSForegroundColorAttributeName : UIColor.purple ]
      for mention in mentions {
        if let start = mention.indices.first,
           let   end = mention.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(attributes, range: range)
        }
      }
    }

#if     FULL_PRETTY_FORMAT
    let retString = NSMutableAttributedString()

    if let name = user?.name {
      let temp = String(format: "%@\n", name)
      let attributes: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15.0),
        NSForegroundColorAttributeName : UIColor.black
      ]
      retString.append(NSAttributedString(string: temp, attributes: attributes))
    }
    if let screenName = user?.screenName {
      let temp = String(format: "@%@\n", screenName)
      let attributes: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 13.0),
        NSForegroundColorAttributeName : UIColor.darkGray
      ]
      retString.append(NSAttributedString(string: temp, attributes: attributes))
    }

    retString.append(tweetString)

    if let dateString = createdAt?.localizedDateString {
      let temp = String(format: "\n%@", dateString)
      retString.append(NSAttributedString(string: temp))
    }
    return retString
#else
    return tweetString
#endif
  }
}

// MARK: - Methods
extension TDKTweet
{
  public func prettyText(with attributes: [TDKTweetAttribute:[String:Any]]? = nil) -> (text: NSAttributedString?, clickable: [String:[String:(NSRange,Any)]]?) {
    guard let text = self.text else {
      return (nil, nil)
    }

    let tweetString = NSMutableAttributedString(string: text)
    let range: NSRange = NSRange(location: 0, length: tweetString.length)
    if let attributes = attributes?[.tweet] {
      tweetString.addAttributes(attributes, range: range)
    }
    else {
      tweetString.addAttributes([
        NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)
      ], range: range)
    }

    var clickable: [String:[String:(NSRange,Any)]] = [:]
    let prettyColor = UIColor(red: 0.0039, green: 0.589844, blue: 0.988281, alpha: 1.0)

    if let hashtags = self.entities?.hashtags {
      var hashtagAttrs: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14.0),
        NSForegroundColorAttributeName : prettyColor
      ]
      if let attributes = attributes?[.hashtag] {
        hashtagAttrs = attributes
      }

      var hashmap: [String:(NSRange,Any)] = [:]
      for hashtag in hashtags {
        if let textRange = text.range(of: "#" + hashtag.text) {
          let range: NSRange = text.nsRange(from: textRange)
          tweetString.addAttributes(hashtagAttrs, range: range)
          hashmap[hashtag.text] = (range, hashtag)
        }
        else
        if let start = hashtag.indices.first,
           let   end = hashtag.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(hashtagAttrs, range: range)
          hashmap[hashtag.text] = (range, hashtag)
        }
      }
      if hashmap.count > 0 {
        clickable["hashtag"] = hashmap
      }
    }

    if let media = self.entities?.media {
      var mediaAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      if let attributes = attributes?[.media] {
        mediaAttrs = attributes
      }

      var mediamap: [String:(NSRange,Any)] = [:]
      for medium in media {
        if let url = medium.url, let textRange = text.range(of: url) {
          let range: NSRange = text.nsRange(from: textRange)
          tweetString.addAttributes(mediaAttrs, range: range)
          mediamap[url] = (range, medium)
        }
        else
        if let start = medium.indices.first,
           let   end = medium.indices.last {
          let  range = NSRange(location: start, length: end - start)
          tweetString.addAttributes(mediaAttrs, range: range)
          if let url = medium.displayUrl {
            mediamap[url] = (range, medium)
          }
        }
      }
      if mediamap.count > 0 {
        clickable["media"] = mediamap
      }
    }

    if let urls = self.entities?.urls {
      var urlAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      if let attributes = attributes?[.url] {
        urlAttrs = attributes
      }

      var urlmap: [String:(NSRange,Any)] = [:]
      for url in urls {
        if let urlStr = url.url, let textRange = text.range(of: urlStr) {
          let range: NSRange = text.nsRange(from: textRange)
          tweetString.addAttributes(urlAttrs, range: range)
          urlmap[urlStr] = (range, url)
        }
      }
      if urlmap.count > 0 {
        clickable["url"] = urlmap
      }
    }

    if let mentions = self.entities?.userMentions {
      var mentionAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor
      ]
      if let attributes = attributes?[.mention] {
        mentionAttrs = attributes
      }

      var mentionmap: [String:(NSRange,Any)] = [:]
      for mention in mentions {
        if let name = mention.screenName,
           let textRange = text.range(of: "@" + name) {
          let range: NSRange = text.nsRange(from: textRange)
          tweetString.addAttributes(mentionAttrs, range: range)
          mentionmap[name] = (range, mention)
        }
      }
      if mentionmap.count > 0 {
        clickable["mention"] = mentionmap
      }
    }

    return (tweetString, clickable)
  }

}


/*
 * nsstring - NSRange to Range<String.Index> - Stack Overflow
 * https://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
 */
extension String {
  func nsRange(from range: Range<String.Index>) -> NSRange {
    let from = range.lowerBound.samePosition(in: utf16)
    let to = range.upperBound.samePosition(in: utf16)
    return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                   length: utf16.distance(from: from, to: to))
  }
}

extension String {
  func range(from nsRange: NSRange) -> Range<String.Index>? {
    guard
      let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
      let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
      let from = from16.samePosition(in: self),
      let to = to16.samePosition(in: self)
      else { return nil }
    return from ..< to
  }
}

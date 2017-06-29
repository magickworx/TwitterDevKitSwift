/*****************************************************************************
 *
 * FILE:	TDKTweetTableCell.swift
 * DESCRIPTION:	TwitterDevKit: Custom UITableViewCell with TDKTweet
 * DATE:	Thu, Jun 15 2017
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

public class TDKTweetTableCell: UITableViewCell
{
  public weak var delegate: TDKClickableActionDelegate? = nil

  let iconView: UIButton = UIButton(type: .custom)
  let nameLabel: UILabel = UILabel()
  let screenLabel: UILabel = UILabel()
  let tweetLabel: UILabel = UILabel()
  let dateLabel: UILabel = UILabel()

  let quotedView: UIView = UIView()
  let quotedName: UILabel = UILabel()
  let quotedScreen: UILabel = UILabel()
  let quotedTweet: UILabel = UILabel()
  let quotedMedia: UIImageView = UIImageView()

  let retweetLabel: UILabel = UILabel()
  let retweetDate: UILabel = UILabel()
  let mediaView: UIImageView = UIImageView()

  var clickableTweetMap: [String:[String:(NSRange,Any)]]? = nil
  var clickableQuoteMap: [String:[String:(NSRange,Any)]]? = nil

  var mediaArray: [TDKMedia] = [] // 添付画像管理用

  public var tweet: TDKTweet? = nil {
    didSet {
      self.composeTweet()
    }
  }

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.selectionStyle = .none

    self.contentView.autoresizesSubviews = false
    self.contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]

    self.contentView.addSubview(iconView)
    self.contentView.addSubview(nameLabel)
    self.contentView.addSubview(screenLabel)
    self.contentView.addSubview(tweetLabel)
    self.contentView.addSubview(dateLabel)

    self.quotedView.addSubview(quotedName)
    self.quotedView.addSubview(quotedScreen)
    self.quotedView.addSubview(quotedTweet)
    self.quotedView.addSubview(quotedMedia)
    self.contentView.addSubview(quotedView)

    self.contentView.addSubview(retweetLabel)
    self.contentView.addSubview(retweetDate)
    self.contentView.addSubview(mediaView)

    iconView.backgroundColor = .lightGray

    nameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)

    screenLabel.font = UIFont.systemFont(ofSize: 14.0)
    screenLabel.textColor = .darkGray

    tweetLabel.font = UIFont.systemFont(ofSize: 16.0)
    tweetLabel.numberOfLines = 0
    tweetLabel.lineBreakMode = .byWordWrapping

    dateLabel.font = UIFont.systemFont(ofSize: 14.0)
    dateLabel.textAlignment = .right

    quotedView.backgroundColor = .clear
    quotedName.font = UIFont.boldSystemFont(ofSize: 14.0)
    quotedScreen.font = UIFont.systemFont(ofSize: 14.0)
    quotedScreen.textColor = .darkGray
    quotedTweet.backgroundColor = .clear
    quotedTweet.font = UIFont.systemFont(ofSize: 14.0)
    quotedTweet.numberOfLines = 0
    quotedTweet.lineBreakMode = .byWordWrapping
    quotedMedia.clipsToBounds = true

    retweetLabel.font = UIFont.systemFont(ofSize: 12.0)
    retweetLabel.textColor = .lightGray
    retweetDate.font = UIFont.systemFont(ofSize: 12.0)
    retweetDate.textColor = .lightGray
    retweetDate.textAlignment = .right

    mediaView.clipsToBounds = true

    self.prepareTapHandlers()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    // 以下に必要なコードを記述する
  }

  func calculatesLayoutSubviews() -> CGSize {
    let  lineHeight: CGFloat = 24.0
    let   lineSpace: CGFloat = 4.0
    let    iconSize: CGFloat = 48.0
    let      margin: CGFloat = 8.0
    let   maxHeight: CGFloat = CGFloat(CGFloat.greatestFiniteMagnitude)

    let  width: CGFloat = self.contentView.frame.size.width
    var height: CGFloat = self.contentView.frame.size.height

    let m: CGFloat = margin
    let s: CGFloat = lineSpace
    var x: CGFloat = m
    var y: CGFloat = m
    var w: CGFloat = iconSize
    var h: CGFloat = w
    iconView.frame = CGRect(x: x, y: y, width: w, height: h)

    x = m + w + m
    w = width - x - m
    h = lineHeight
    nameLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += h

    screenLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += (h + s)

    if let text = tweetLabel.attributedText {
      let constraintSize = CGSize(width: w, height: maxHeight)
      let size = text.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil).size
      h = size.height
    }
    else if let text = tweetLabel.text {
      var lang: String = Locale.preferredLanguages[0]
      lang = lang.substring(to: lang.index(lang.startIndex, offsetBy: 2))
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineBreakMode = tweetLabel.lineBreakMode
      let attributes: [String:Any] = [
        kCTLanguageAttributeName as String : lang, // 禁則処理を言語に合わせる
        NSFontAttributeName : tweetLabel.font,
        NSParagraphStyleAttributeName : paragraphStyle
      ]
      let constraintSize = CGSize(width: w, height: maxHeight)
      let size = text.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
      h = size.height
    }
    tweetLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += (h + s)

    h = lineHeight
    dateLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += h

    if let text = quotedTweet.text {
      if text.characters.count > 0 {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = quotedTweet.lineBreakMode
        let attributes: [String:Any] = [
          NSFontAttributeName : quotedTweet.font,
          NSParagraphStyleAttributeName : paragraphStyle
        ]
        let qw: CGFloat = w - m * 2.0
        let constraintSize = CGSize(width: qw, height: maxHeight)
        let size = text.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let qh: CGFloat = size.height + m * 2.0
        h = lineHeight + lineHeight + s + qh + s
        if let quoted = self.tweet?.quotedStatus {
          if let media = quoted.entities?.media, !media.isEmpty {
            let th = floor(qw * 0.75)
            quotedMedia.frame = CGRect(x: m, y: h, width: qw, height: th)
            h += (th + m)
          }
          else {
            quotedMedia.frame = CGRect.zero
          }
        }
        quotedView.frame = CGRect(x: x, y: y, width: w, height: h)
        do {
          let tx = m
          var ty = m
          let tw = qw
          var th = lineHeight
          quotedName.frame = CGRect(x: tx, y: ty, width: tw, height: th)
          ty += th
          quotedScreen.frame = CGRect(x: tx, y: ty, width: tw, height: th)
          ty += th
          th = qh
          quotedTweet.frame = CGRect(x: tx, y: ty, width: tw, height: th)
        }
        y += h
      }
    }
    else {
      quotedView.frame = CGRect.zero
      quotedName.frame = CGRect.zero
      quotedScreen.frame = CGRect.zero
      quotedTweet.frame = CGRect.zero
      quotedMedia.frame = CGRect.zero
    }

    if let text = retweetLabel.text, text.characters.count > 0 {
      h = lineHeight - 4.0
      retweetLabel.frame = CGRect(x: x, y: y, width: w, height: h)
      y += h
    }
    else {
      retweetLabel.frame = CGRect.zero
    }

    if let text = retweetDate.text, text.characters.count > 0 {
      h = lineHeight - 4.0
      retweetDate.frame = CGRect(x: x, y: y, width: w, height: h)
      y += h
    }
    else {
      retweetDate.frame = CGRect.zero
    }

    if let tweet = self.tweet {
      var status: TDKTweet = tweet
      if let retweetedStatus = tweet.retweetedStatus {
        status = retweetedStatus
      }
      if let media = status.entities?.media, !media.isEmpty {
        h = floor(w * 0.75)
        mediaView.frame = CGRect(x: x, y: y, width: w, height: h)
        y += h
      }
      else {
        mediaView.frame = CGRect.zero
      }
    }

    y += 4.0 // 最下部の余白
    height = ceil(y)

    return CGSize(width: width, height: height)
  }

  override public func prepareForReuse() {
    iconView.setImage(nil, for: .normal)
    nameLabel.text = nil
    screenLabel.text = nil
    tweetLabel.text = nil
    dateLabel.text = nil

    quotedName.text = nil
    quotedScreen.text = nil
    quotedTweet.text = nil
    quotedMedia.image = nil

    retweetLabel.text = nil
    retweetDate.text = nil
    mediaView.image = nil

    mediaArray.removeAll()

    super.prepareForReuse()
  }

  override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    return self.calculatesLayoutSubviews()
  }
}

// MARK: - Updates Content
extension TDKTweetTableCell
{
  func composeTweet() {
    guard let tweet = self.tweet else { return }
    if let quotedStatus = tweet.quotedStatus {
      let pretty = quotedStatus.prettyPrinted()
      if let clickable = pretty.clickable {
        if clickable.count > 0 {
          clickableQuoteMap = clickable
        }
      }
      if let user = quotedStatus.user {
        if let name = user.name {
          quotedName.text = name
        }
        if let screen = user.screenName {
          quotedScreen.text = "@" + screen
        }
      }
      if let text = pretty.text {
        quotedTweet.attributedText = text
        quotedView.layer.borderWidth = 1.0
        quotedView.layer.borderColor = UIColor.lightGray.cgColor
        quotedView.layer.cornerRadius = 4.0
        quotedView.layer.masksToBounds = true
      }
      if let media = quotedStatus.entities?.media {
        self.fetchMedia(media, quoted: true)
      }
    }

    var status: TDKTweet = tweet
    if let retweetedStatus = tweet.retweetedStatus {
      status = retweetedStatus

      if let name = tweet.user?.name {
        retweetLabel.text = "RT: \(name)"
      }
      if let date = tweet.createdAt?.localizedDateString {
        retweetDate.text = date
      }
    }

    let pretty = status.prettyPrinted()
    if let clickable = pretty.clickable {
      if clickable.count > 0 {
        clickableTweetMap = clickable
      }
    }
    if let text = pretty.text {
      tweetLabel.attributedText = text
    }

    if let date = status.createdAt?.localizedDateString {
      dateLabel.text = date
    }

    if let name = status.user?.name {
      nameLabel.text = name
    }

    if let screen = status.user?.screenName {
      screenLabel.text = "@" + screen
    }

    if let url = status.user?.profileImageUrlHttps {
      fetchUserIcon(with: url)
    }
    else if let url = status.user?.profileImageUrl {
      fetchUserIcon(with: url)
    }

    if let media = status.entities?.media {
      self.fetchMedia(media)
    }

    if let coordinates = status.coordinates, coordinates.type.lowercased() == "point" {
      dump(coordinates)
    }
    if let place = status.place {
      dump(place)
    }
    if status.possiblySensitive {
      print("sensitive")
    }
  }
}

// MARK: - Tap Handler
/*
 * iphone - iOS: Find url in string and change the string to be clickable (tapable) - Stack Overflow
 *  https://stackoverflow.com/questions/16172236/ios-find-url-in-string-and-change-the-string-to-be-clickable-tapable
 */
extension TDKTweetTableCell
{
  func prepareTapHandlers() {
    tweetLabel.isUserInteractionEnabled = true
    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTweetHandler))
    tweetLabel.addGestureRecognizer(tapGesture)

    quotedTweet.isUserInteractionEnabled = true
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapQuoteHandler))
    quotedTweet.addGestureRecognizer(tapGesture)

    iconView.addTarget(self, action: #selector(tapIconHandler), for: .touchUpInside)

    quotedMedia.isUserInteractionEnabled = true
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMediaHandler))
    quotedMedia.addGestureRecognizer(tapGesture)

    mediaView.isUserInteractionEnabled = true
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMediaHandler))
    mediaView.addGestureRecognizer(tapGesture)
  }

  func tapTweetHandler(gesture: UITapGestureRecognizer) {
    if let clickable = self.clickableTweetMap {
      let tapLocation: CGPoint = gesture.location(in: tweetLabel)
      self.detectAction(with: clickable, at: tapLocation, in: tweetLabel)
    }
  }

  func tapQuoteHandler(gesture: UITapGestureRecognizer) {
    if let clickable = self.clickableQuoteMap {
      let tapLocation: CGPoint = gesture.location(in: quotedTweet)
      self.detectAction(with: clickable, at: tapLocation, in: quotedTweet)
    }
  }

  func detectAction(with clickableMap: [String:[String:(NSRange,Any)]], at point: CGPoint, in label: UILabel) {
    let indexOfCharacter = didTapAttributedText(in: label, at: point)

    clickableMap.forEach {
      let key: String = $0
      let val: [String:(NSRange,Any)] = $1
      for (text, tuple) in val {
        let (range, entity) = tuple
        if NSLocationInRange(indexOfCharacter, range) {
          if let delegate = self.delegate, let tweet = self.tweet {
            var action: TDKClickableActionType
            switch key {
              case "hashtag":
                guard let hashtag = entity as? TDKHashtag else { return }
                action = .hashtag(hashtag, text)
              case "media":
                guard let media = entity as? TDKMedia else { return }
                action = .media(media, text)
              case "url":
                guard let url = entity as? TDKURL else { return }
                action = .url(url, text)
              case "mention":
                guard let mention = entity as? TDKUserMention else { return }
                action = .mention(mention, text)
              default:
                return
            }
            delegate.clickableAction(action, in: tweet)
          }
          else {
            print("\(key): \(text)")
          }
        }
      }
    }
  }

  func didTapAttributedText(in label: UILabel, at location: CGPoint) -> Int {
    if let attributedString = label.attributedText {
      let attributedText = NSMutableAttributedString(attributedString: attributedString)
      var lang: String = Locale.preferredLanguages[0]
      lang = lang.substring(to: lang.index(lang.startIndex, offsetBy: 2))
      attributedText.addAttributes([
        kCTLanguageAttributeName as String : lang, // 禁則処理を言語に合わせる
        NSFontAttributeName: label.font
      ], range: NSMakeRange(0, attributedString.string.glyphCount))
      // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
      let layoutManager = NSLayoutManager()
      let textContainer = NSTextContainer(size: label.frame.size)
      let textStorage = NSTextStorage(attributedString: attributedText)
      // Configure layoutManager and textStorage
      layoutManager.addTextContainer(textContainer)
      layoutManager.usesFontLeading = true
      textStorage.addLayoutManager(layoutManager)
      // Configure textContainer
      textContainer.lineFragmentPadding = 0.0
      textContainer.lineBreakMode = label.lineBreakMode
      textContainer.maximumNumberOfLines = label.numberOfLines
      // get the index of character where user tapped
      let indexOfCharacter = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

      return indexOfCharacter
    }

    return -1
  }

  func tapIconHandler(sender: UIButton) {
    if var status = self.tweet {
      if let retweetedStatus = status.retweetedStatus {
        status = retweetedStatus
      }
      if let delegate = self.delegate, let tweet = self.tweet, let user = status.user {
        let action = TDKClickableActionType.icon(user)
        delegate.clickableAction(action, in: tweet)
      }
      else {
        dump(status.user)
      }
    }
  }

  func tapMediaHandler(gesture: UITapGestureRecognizer) {
    if var status = self.tweet {
      if let retweetedStatus = status.retweetedStatus {
        status = retweetedStatus
      }
      if let delegate = self.delegate, let tweet = self.tweet {
        if let view = gesture.view as? UIImageView, let image = view.image {
          let action = TDKClickableActionType.image(mediaArray, image)
          delegate.clickableAction(action, in: tweet)
        }
      }
      else {
        dump(status.entities?.media)
      }
    }
  }
}

// MARK: - Downloader
extension TDKTweetTableCell
{
  func fetchUserIcon(with urlString: String) {
    TDKImageCacheLoader.shared.fetchImage(with: urlString, completion: {
      [weak self] (image: UIImage?, error: Error?) in
      guard error == nil else { return }
      if let weakSelf = self, let image = image {
        weakSelf.iconView.setImage(image, for: .normal)
        weakSelf.iconView.backgroundColor = .clear
        let bounds = weakSelf.iconView.bounds
        let radius = bounds.width * 0.5
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        weakSelf.iconView.layer.mask = maskLayer;
      }
    })
  }

  func fetchMedia(_ mediaArray: [TDKMedia], quoted: Bool = false) {
    let width = Float(self.contentView.bounds.size.width)
    for media in mediaArray {
      if let type = media.type, let mediaUrlHttps = media.mediaUrlHttps {
        if type.lowercased() == "photo" {
          var   url: String = mediaUrlHttps
          var  size: String = "medium" // tiwtter default
          var ratio:  Float = Float(Float.greatestFiniteMagnitude)
          // 画面の横幅の比率に応じてサイズを自動決定するよ
          if let sizes = media.sizes {
            if let large = sizes.large {
              let w = Float(large.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "large"
                ratio = r
              }
            }
            if let medium = sizes.medium {
              let w = Float(medium.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "medium"
                ratio = r
              }
            }
            if let small = sizes.small {
              let w = Float(small.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "small"
                ratio = r
              }
            }
          }
          url = url + ":" + size
          self.fetchImage(with: url, quoted: quoted)
          self.mediaArray.append(media)
          break
        }
      }
    }
  }

  func fetchImage(with urlString: String, quoted: Bool = false) {
    let kCacheTime : TimeInterval = 5 * 60 // 300 seconds

    if let iconUrl = URL(string: urlString) {
      let req = URLRequest(url: iconUrl,
                           cachePolicy: .returnCacheDataElseLoad,
                           timeoutInterval: kCacheTime)
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      session.dataTask(with: req, completionHandler: {
        [weak self] (data, response, error) in
        if error == nil {
          if let weakSelf = self, let imageData = data, let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
              let w = image.size.width
              let h = image.size.height
              if quoted {
                weakSelf.quotedMedia.contentMode = w < h ? .center : .scaleAspectFit
                weakSelf.quotedMedia.image = image
              }
              else {
                weakSelf.mediaView.contentMode = w < h ? .center : .scaleAspectFit
                weakSelf.mediaView.image = image
              }
              weakSelf.contentView.setNeedsDisplay()
            }
          }
          else {
            // XXX: Nothing to do now...
          }
        }
        else {
          dump(error)
        }
        session.finishTasksAndInvalidate()
      }).resume()
    }
  }
}

/*
 * ios - Find out if Character in String is emoji? - Stack Overflow
 * https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
 */
fileprivate extension String {
  var glyphCount: Int {
    let richText = NSAttributedString(string: self)
    let line = CTLineCreateWithAttributedString(richText)
    return CTLineGetGlyphCount(line)
  }

  func containsEmoji() -> Bool {
    for scalar in unicodeScalars {
      switch scalar.value {
        case 0x3030, 0x00AE, 0x00A9,// Special Characters
             0x1D000...0x1F77F,     // Emoticons
              0x2100...0x27BF,      // Misc symbols and Dingbats
              0xFE00...0xFE0F,      // Variation Selectors
             0x1F900...0x1F9FF:     // Supplemental Symbols and Pictographs
          return true
        default:
          continue
      }
    }
    return false
  }
}

/*****************************************************************************
 *
 * FILE:	TDKJSON.swift
 * DESCRIPTION:	TwitterDevKit: JSON Parser for Responses from Twitter API
 * DATE:	Sun, Jun 11 2017
 * UPDATED:	Sun, Jun 18 2017
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

public enum JSONError: Error {
  case failed(String)
  case invalidJSONObject
}

public struct JSON: Equatable {
  // MARK: - Override ==
  public static func ==(lhs: JSON, rhs: JSON) -> Bool {
    return (lhs.source as? NSObject) == (rhs.source as? NSObject)
  }

  public static var dateFormatter = DateFormatter()

  public static let null = JSON()

  internal(set) var source: Any

  internal init() {
    self.init(source: nil)
  }

  internal init(source: Any?) {
    // UTC time like "Wed Aug 27 13:08:45 +0000 2008"
    JSON.dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    JSON.dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    if let source = source {
      self.source = source as Any
    }
    else {
      self.source = NSNull()
    }
  }

  public init(_ data: Data?) {
    let source = JSON.object(with: data)
    self.init(source: source)
  }

  public init(_ string: String?) {
    let source = string?.data(using: String.Encoding.utf8)
    self.init(source: source)
  }

  public init(_ source: Any?) {
    self.init(source: source)
  }
}

// MARK: - Class Methos
extension JSON {
  static func object(with data: Data?) -> Any? {
    guard let data = data else { return nil }
    return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
  }
}

// MARK: - Properties
extension JSON {
  public var json: JSON { return self }

  public var bool: Bool? { return source as? Bool }

  public var int: Int? { return number?.intValue }
  public var int64: Int64? { return number?.int64Value }
  public var float: Float? { return number?.floatValue }
  public var double: Double? { return number?.doubleValue }
  public var number: NSNumber? { return source as? NSNumber }

  public var array: [Any]? { return source as? [Any] }
  public var dictionary: [String: Any]? { return source as? [String: Any] }

  public var string: String? { return source as? String }

  public var date: Date? {
    if let dateString = string {
      if let date = JSON.dateFormatter.date(from: dateString) {
        return date
      }
    }
    return nil
  }

  public var url: URL? {
    if let string = string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
      return URL(string: string)
    }
    return nil
  }
}

// MARK: - Subscript
extension JSON {
  public subscript(key: String) -> JSON {
    guard let dictionary = dictionary else {
      return JSON.null
    }
    return JSON(dictionary[key])
  }

  public subscript(index: Int) -> JSON {
    guard let array = array else {
      return JSON.null
    }
    return JSON(array[index])
  }
}

// MARK: - Properties
extension JSON {
  fileprivate enum SourceTypes {
    case typeInt
    case typeInt64
    case typeFloat
    case typeDouble
    case typeString
    case typeArray
    case typeDictionary
    case typeUnknown
  }

  fileprivate func type(of source: Any) -> SourceTypes {
    if source is Int    { return .typeInt }
    if source is Int64  { return .typeInt64 }
    if source is Float  { return .typeFloat }
    if source is Double { return .typeDouble }
    if source is String { return .typeString }
    if source is Array<Any>  { return .typeArray }
    if source is Dictionary<String,Any> { return .typeDictionary }
    return .typeUnknown
  }

  public var count: Int {
    switch self.type(of: source as Any) {
      case .typeString:
        return 0
      case .typeInt, .typeInt64, .typeDouble, .typeFloat:
        return 0
      case .typeArray:
        guard let count = array?.count else { return 0 }
        return count
      case .typeDictionary:
        guard let count = dictionary?.count else { return 0 }
        return count
      case .typeUnknown:
        return 0
    }
  }
}

// MARK: - Sequence
extension JSON: Sequence {
  public func makeIterator() -> AnyIterator<JSON> {
    guard let array = array else {
      return AnyIterator { nil }
    }

    var index = 0
    return AnyIterator {
      guard index < array.count else { return nil }
      let source = array[index]
      index += 1
      return JSON(source)
    }
  }
}

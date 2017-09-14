/*****************************************************************************
 *
 * FILE:	TDKPlaces.swift
 * DESCRIPTION:	TwitterDevKit: Places Structures for Entity of Twitter
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Wed, Sep 13 2017
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
public struct TDKCoordinates {
  public internal(set) var coordinates: [Double] = [] // [longitude, latitude]
  public internal(set) var type: String = "" // "Point",...

  public init(_ json: JSON) {
    if let type = json["type"].string {
      self.type = type
    }
    if let coordinates = json["coordinates"].array as? [Double] {
      self.coordinates = coordinates
    }
  }
}

// Deprecated field, but some clients use this field yet...
public struct TDKGeo {
  public internal(set) var coordinates: [Double] = [] // [latitude, longitude]
  public internal(set) var type: String = "" // "Point",...

  public init(_ json: JSON) {
    if let type = json["type"].string {
      self.type = type
    }
    if let coordinates = json["coordinates"].array as? [Double] {
      self.coordinates = coordinates
    }
  }
}


public typealias TDKBoundingBoxType = [[[Double]]]

// https://dev.twitter.com/overview/api/places
public struct TDKPlaceBoundingBox {
  public internal(set) var coordinates: TDKBoundingBoxType = []
  public internal(set) var type: String? = nil

  public init(_ json: JSON) {
    if let type = json["type"].string {
      self.type = type
    }
    if let coordinates = json["coordinates"].array as? TDKBoundingBoxType {
      self.coordinates = coordinates
    }
  }
}

// https://dev.twitter.com/overview/api/places
public struct TDKPlaceAttributes {
  public internal(set) var twitter: String? = nil

  public internal(set) var streetAddress: String? = nil
  public internal(set) var locality: String? = nil
  public internal(set) var region: String? = nil
  public internal(set) var iso3: String? = nil
  public internal(set) var postalCode: String? = nil
  public internal(set) var phone: String? = nil
  public internal(set) var url: String? = nil
  public internal(set) var appId: String? = nil

  public init(_ json: JSON) {
    if let twitter = json["twitter"].string {
      self.twitter = twitter
    }

    if let sval = json["street_address"].string {
      self.streetAddress = sval
    }
    if let sval = json["locality"].string {
      self.locality = sval
    }
    if let sval = json["region"].string {
      self.region = sval
    }
    if let sval = json["iso3"].string {
      self.iso3 = sval
    }
    if let sval = json["postal_code"].string {
      self.postalCode = sval
    }
    if let sval = json["phone"].string {
      self.phone = sval
    }
    if let sval = json["url"].string {
      self.url = sval
    }
    if let sval = json["appId"].string {
      self.appId = sval
    }
  }
}

// https://dev.twitter.com/overview/api/places
public struct TDKPlaces {
  public internal(set) var id: String? = nil
  public internal(set) var name: String? = nil

  public internal(set) var attributes: TDKPlaceAttributes? = nil
  public internal(set) var boundingBox: TDKPlaceBoundingBox? = nil
  public internal(set) var country: String? = nil
  public internal(set) var countryCode: String? = nil
  public internal(set) var fullName: String? = nil
  public internal(set) var placeType: String? = nil
  public internal(set) var url: String? = nil

  public init(_ json: JSON) {
    if let id = json["id"].string {
      self.id = id
    }
    if let name = json["name"].string {
      self.name = name
    }

    if json["attributes"].dictionary != nil {
      self.attributes = TDKPlaceAttributes(json["attributes"])
    }
    if json["bounding_box"].dictionary != nil {
      self.boundingBox = TDKPlaceBoundingBox(json["bounding_box"])
    }
    if let sval = json["country"].string {
      self.country = sval
    }
    if let sval = json["country_code"].string {
      self.countryCode = sval
    }
    if let sval = json["full_name"].string {
      self.fullName = sval
    }
    if let sval = json["place_type"].string {
      self.placeType = sval
    }
    if let sval = json["url"].string {
      self.url = sval
    }
  }
}

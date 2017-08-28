/*****************************************************************************
 *
 * FILE:	TDKImageCacheLoader.swift
 * DESCRIPTION:	TwitterDevKit: Asynchoronous Image Downloader with Cache
 * DATE:	Sun, Jun 18 2017
 * UPDATED:	Sun, Aug 27 2017
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

public typealias TDKImageCacheLoaderCompletionHandler = (UIImage?, Error?)->Void

public final class TDKImageCacheLoader
{
  public static let shared: TDKImageCacheLoader = TDKImageCacheLoader()

  let cache = NSCache<NSString, UIImage>()
  let session = URLSession.shared

  public func fetchImage(with urlString: String, cachedTime: TimeInterval = 300, completion: @escaping TDKImageCacheLoaderCompletionHandler) {
    if let image = cache.object(forKey: urlString as NSString) {
      DispatchQueue.main.async {
        completion(image, nil)
      }
    }
    else if let url = URL(string: urlString) {
      let req = URLRequest(url: url,
                           cachePolicy: .returnCacheDataElseLoad,
                           timeoutInterval: cachedTime)
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      session.dataTask(with: req, completionHandler: {
        (data, response, error) in
        guard error == nil, let image = UIImage(data: data!) else {
          DispatchQueue.main.async {
            completion(nil, error)
          }
          return
        }
        self.cache.setObject(image, forKey: urlString as NSString)
        DispatchQueue.main.async {
          completion(image, nil)
        }
      }).resume()
    }
  }
}

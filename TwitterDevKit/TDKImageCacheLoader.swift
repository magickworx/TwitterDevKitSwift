/*****************************************************************************
 *
 * FILE:	TDKImageCacheLoader.swift
 * DESCRIPTION:	TwitterDevKit: Asynchoronous Image Downloader with Cache
 * DATE:	Sun, Jun 18 2017
 * UPDATED:	Tue, Nov  7 2017
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

  let fileManager = FileManager.default
  var cacheURL: URL

  let cache = NSCache<NSString, UIImage>()
  let session = URLSession.shared

  init() {
    cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
}

extension TDKImageCacheLoader
{
  public func fetchImage(with urlString: String, usingDisk: Bool = false, resized size: CGSize = .zero, cachedTime: TimeInterval = 300, completion: @escaping TDKImageCacheLoaderCompletionHandler) {
    let finished = { [unowned self] (_ image: UIImage, _ key: String) in
      self.cache.setObject(image, forKey: key as NSString)
      DispatchQueue.main.async {
        completion(image, nil)
      }
    }

    let cacheKey = URL(string: urlString)!.lastPathComponent.replacingOccurrences(of: ":", with: "__")
    let fileURL = cacheFileURL(forKey: cacheKey)

    if let image = cache.object(forKey: cacheKey as NSString) {
      DispatchQueue.main.async {
        completion(image, nil)
      }
    }
    else if fileManager.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL) {
      let image = UIImage(data: data)
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
        if usingDisk, let data = data {
          let fileURL = self.cacheFileURL(forKey: cacheKey)
          try? data.write(to: fileURL, options: .atomic)
        }
        if size.width > 0 && size.height > 0 {
          if let resizedImage = image.resize(to: size) {
            let key = String(format: "%@+%.0fx%.0f", cacheKey, size.width, size.height)
            finished(resizedImage, key)
          }
          else {
            finished(image, cacheKey)
          }
        }
        else {
          finished(image, cacheKey)
        }
      }).resume()
    }
  }

  fileprivate func cacheFileURL(forKey key: String) -> URL {
    let filename = "cache+" + key + ".tdk"
    return cacheURL.appendingPathComponent(filename)
  }

  public func clearDiskCache() {
    if let enumerator = fileManager.enumerator(at: cacheURL, includingPropertiesForKeys: [], options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles], errorHandler: nil) {
      if let fileURLs = enumerator.allObjects as? [URL] {
        fileURLs.filter({ $0.path.contains(".tdk") }).forEach {
          [unowned self] (url: URL) in
          try? self.fileManager.removeItem(at: url)
        }
      }
    }
  }
}

fileprivate extension UIImage
{
  func resize(to newSize: CGSize) -> UIImage? {
    let  widthRatio = newSize.width  / size.width
    let heightRatio = newSize.height / size.height
    let resizeRatio = widthRatio < heightRatio ? widthRatio : heightRatio
    let resizedSize = CGSize(width: size.width * resizeRatio, height: size.height * resizeRatio)
    let opaque: Bool = false
    let  scale: CGFloat = 0.0

    UIGraphicsBeginImageContextWithOptions(resizedSize, opaque, scale)
    if let context = UIGraphicsGetCurrentContext() {
      context.interpolationQuality = .high
    }
    draw(in: CGRect(origin: .zero, size: resizedSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }
}

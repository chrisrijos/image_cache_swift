class MyImageCache {

    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()

}

extension NSURL {

    typealias ImageCacheCompletion = UIImage -> Void

    var cachedImage: UIImage? {
        return MyImageCache.sharedCache.objectForKey(
            absoluteString) as? UIImage
    }

    func fetchImage(completion: ImageCacheCompletion) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(self) {
            data, response, error in
            if error == nil {
                if let  data = data,
                        image = UIImage(data: data) {
                    MyImageCache.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString,
                        cost: data.length)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }
}

/*
override func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = models[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath) as! MyCell
        cell.textLabel?.text = data.text

        // Image loading.
        cell.imageUrl = data.imageUrl // For recycled cells' late image loads.
        if let image = data.imageUrl.cachedImage {
            // Cached: set immediately.
            cell.myImageView.image = image
            cell.myImageView.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.myImageView.alpha = 0
            data.imageUrl.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                if cell.imageUrl == data.imageUrl {
                    cell.myImageView.image = image
                    UIView.animateWithDuration(0.3) {
                        cell.myImageView.alpha = 1
                    }
                }
            }
        }

        return cell
}
*/

//
//  AsyncMMSFetcher.swift
//  Telabook
//
//  Created by Anmol Rajpal on 18/07/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
class AsyncMMSFetcherOperation: Operation {
    // MARK: Properties

    /// The `UUID` that the operation is fetching data for.
    let url: URL

    /// The `DisplayData` that has been fetched by this operation.
    private(set) var fetchedImage: UIImage?

    // MARK: Initialization

    init(localURL: URL) {
        self.url = localURL
    }
    
    func getImageData() -> Data? {
        var imageData:Data?
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: url, options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                if let data = try? Data(contentsOf: newURL) {
                    imageData = data
                }
        })
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }
        return imageData
    }
    
    // MARK: Operation overrides

    override func main() {
        guard !isCancelled else { return }
        if let data = getImageData() {
            fetchedImage = UIImage(data: data)
        }
    }
}
class AsyncMMSFetcher {
    // MARK: Types

    /// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
    private let serialAccessQueue = OperationQueue()

    /// An `OperationQueue` that contains `AsyncFetcherOperation`s for requested data.
    private let fetchQueue = OperationQueue()

    /// A dictionary of arrays of closures to call when an object has been fetched for an id.
    private var completionHandlers = [NSURL: [(UIImage?) -> Void]]()

    /// An `NSCache` used to store fetched objects.
    private var cache = NSCache<NSURL, UIImage>()

    // MARK: Initialization

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }

    
    
    
    // MARK: Object fetching

    /**
     Asynchronously fetches data for a specified `UUID`.
     
     - Parameters:
         - identifier: The `UUID` to fetch data for.
         - completion: An optional called when the data has been fetched.
    */
    func fetchAsync(_ sourceURL: URL, completion: ((UIImage?) -> Void)? = nil) {
        // Use the serial queue while we access the fetch queue and completion handlers.
        serialAccessQueue.addOperation {
            // If a completion block has been provided, store it.
            if let completion = completion {
                let handlers = self.completionHandlers[sourceURL as NSURL, default: []]
                self.completionHandlers[sourceURL as NSURL] = handlers + [completion]
            }
            
            self.fetchImage(for: sourceURL)
        }
    }

    /**
     Returns the previously fetched data for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the object to return.
     - Returns: The 'DisplayData' that has previously been fetched or nil.
     */
    func fetchedImage(for sourceURL: URL) -> UIImage? {
        return cache.object(forKey: sourceURL as NSURL)
    }
    
    
    func clearCache(for urls:[URL]) {
        urls.forEach { cache.removeObject(forKey: $0 as NSURL) }
    }
    func clearAllCache() {
        cache.removeAllObjects()
    }
    
    /**
     Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
     handlers are not called if a fetch is canceled.
     
     - Parameter identifier: The `UUID` to cancel fetches for.
     */
    func cancelFetch(_ sourceURL: URL) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: sourceURL)?.cancel()
            self.completionHandlers[sourceURL as NSURL] = nil
        }
    }

    // MARK: Convenience
    
    /**
     Begins fetching data for the provided `identifier` invoking the associated
     completion handler when complete.
     
     - Parameter identifier: The `UUID` to fetch data for.
     */
    private func fetchImage(for sourceURL: URL) {
        // If a request has already been made for the object, do nothing more.
        guard operation(for: sourceURL) == nil else { return }
        
        if let data = fetchedImage(for: sourceURL) {
            // The object has already been cached; call the completion handler with that object.
            invokeCompletionHandlers(for: sourceURL as NSURL, with: data)
        } else {
            // Enqueue a request for the object.
            let operation = AsyncMMSFetcherOperation(localURL: sourceURL)
            
            // Set the operation's completion block to cache the fetched object and call the associated completion blocks.
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedImage else { return }
                self.cache.setObject(fetchedData, forKey: sourceURL as NSURL)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: sourceURL as NSURL, with: fetchedData)
                }
            }
            
            fetchQueue.addOperation(operation)
        }
    }

    /**
     Returns any enqueued `ObjectFetcherOperation` for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the operation to return.
     - Returns: The enqueued `ObjectFetcherOperation` or nil.
     */
    private func operation(for sourceURL: URL) -> AsyncMMSFetcherOperation? {
        for case let fetchOperation as AsyncMMSFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.url == sourceURL {
            return fetchOperation
        }
        
        return nil
    }

    /**
     Invokes any completion handlers for a specified `UUID`. Once called,
     the stored array of completion handlers for the `UUID` is cleared.
     
     - Parameters:
     - identifier: The `UUID` of the completion handlers to call.
     - object: The fetched object to pass when calling a completion handler.
     */
    private func invokeCompletionHandlers(for sourceURL: NSURL, with fetchedImage: UIImage) {
        let completionHandlers = self.completionHandlers[sourceURL, default: []]
        self.completionHandlers[sourceURL] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedImage)
        }
    }
}

//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				
				guard response.statusCode == 200,
					  let root = try? decoder.decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.items.map({$0.toFeedImage()})))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

struct Root: Decodable {
	var items: [Feed]
	
	struct Feed: Decodable {
		var imageId: UUID
		var imageDesc: String?
		var imageLoc: String?
		var imageUrl: URL
		
		func toFeedImage() -> FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
	}
}

//FeedAPIChallenge.FeedImage(id: 5A50A434-F426-49E9-86AD-42F277F62122, description: nil, location: nil, url: http://a-url.com)

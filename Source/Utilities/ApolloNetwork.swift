import Foundation
import Apollo

final class Network {
    // Singleton pattern
    static let shared = Network()
    
    fileprivate let accessToken = "<your_token>"
    private let apiURL = "https://api.cyanite.ai/graphql"
    
    lazy var apollo: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        let client = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
        let provider = NetworkInterceptorProvider(client: client, shouldInvalidateClientOnDeinit: true, store: store)
        
        guard let url = URL(string: apiURL) else {
            fatalError("Invalid URL")
        }
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: url)
        
        return ApolloClient(networkTransport: requestChainTransport, store: store)
    }()
    
    private init() {}
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(CustomInterceptor(accessToken: Network.shared.accessToken), at: 0)
        return interceptors
    }
}

class CustomInterceptor: ApolloInterceptor {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        request.addHeader(name: "Authorization", value: "Bearer \(accessToken)")
        
        print("Request: \(request)")
        print("Response: \(String(describing: response))")
        
        chain.proceedAsync(request: request, response: response, completion: completion)
    }
}

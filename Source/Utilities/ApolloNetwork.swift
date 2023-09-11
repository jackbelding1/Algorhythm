import Foundation
import Apollo

final class Network {
    // Singleton pattern
    static let shared = Network()
    
    fileprivate let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiSW50ZWdyYXRpb25BY2Nlc3NUb2tlbiIsInZlcnNpb24iOiIxLjAiLCJpbnRlZ3JhdGlvbklkIjozODUsInVzZXJJZCI6MTM2OTIsImFjY2Vzc1Rva2VuU2VjcmV0IjoiOTI3ZDY3NTRjYjNiYmUzMDIyNjdlOGE1ZGQxMjljZGZlYWU3ODFmN2E4NDk5NTJhMjE2OGJiOTY5OGYwMTAyMSIsImlhdCI6MTY2NzUxNTU3NX0.SfOYdyel-dab7ubG_3brp64gwE7sVtue9ODnnPPa_cE"
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

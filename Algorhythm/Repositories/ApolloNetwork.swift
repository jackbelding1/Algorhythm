//
//  Apollo.swift
//  XcodersGraphQL
//
//

import Foundation
import Apollo

class Network {
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiSW50ZWdyYXRpb25BY2Nlc3NUb2tlbiIsInZlcnNpb24iOiIxLjAiLCJpbnRlZ3JhdGlvbklkIjozODUsInVzZXJJZCI6MTM2OTIsImFjY2Vzc1Rva2VuU2VjcmV0IjoiOTI3ZDY3NTRjYjNiYmUzMDIyNjdlOGE1ZGQxMjljZGZlYWU3ODFmN2E4NDk5NTJhMjE2OGJiOTY5OGYwMTAyMSIsImlhdCI6MTY2NzUxNTU3NX0.SfOYdyel-dab7ubG_3brp64gwE7sVtue9ODnnPPa_cE"
    static let shared = Network()
    
    lazy var apollo: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store1 = ApolloStore(cache: cache)
        let authPayloads = ["Authorization": "Bearer \(accessToken)"]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads
        
        let client1 = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
        let provider = NetworkInterceptorProvider(client: client1, shouldInvalidateClientOnDeinit: true, store: store1)
        
        let url = URL(string: "https://api.cyanite.ai/graphql")!
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: url)
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store1)
    }()
    

    
    private init() {
        
    }
}
     
class NetworkInterceptorProvider: DefaultInterceptorProvider {
 override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
     var interceptors = super.interceptors(for: operation)
     interceptors.insert(CustomInterceptor(), at: 0)
     return interceptors
 }
}
class CustomInterceptor: ApolloInterceptor {
 
 func interceptAsync<Operation: GraphQLOperation>(
     chain: RequestChain,
     request: HTTPRequest<Operation>,
     response: HTTPResponse<Operation>?,
     completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
     request.addHeader(name: "Authorization", value: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiSW50ZWdyYXRpb25BY2Nlc3NUb2tlbiIsInZlcnNpb24iOiIxLjAiLCJpbnRlZ3JhdGlvbklkIjozODUsInVzZXJJZCI6MTM2OTIsImFjY2Vzc1Rva2VuU2VjcmV0IjoiOTI3ZDY3NTRjYjNiYmUzMDIyNjdlOGE1ZGQxMjljZGZlYWU3ODFmN2E4NDk5NTJhMjE2OGJiOTY5OGYwMTAyMSIsImlhdCI6MTY2NzUxNTU3NX0.SfOYdyel-dab7ubG_3brp64gwE7sVtue9ODnnPPa_cE")
     
     print("request :\(request)")
     print("response :\(String(describing: response))")
     
     chain.proceedAsync(request: request,
                        response: response,
                        completion: completion)
 }
}


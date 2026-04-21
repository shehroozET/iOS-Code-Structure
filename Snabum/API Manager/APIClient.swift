//
//  APIClient.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Alamofire

enum APIError: Error {
    case network(description: String)
    case server(message: String)
    case parsing
    case unknown
    case backendError(data: Data)
    
    var localizedDescription: String {
        switch self {
        case .network(let desc): return "Network error: \(desc)"
        case .server(let msg): return "Server error: \(msg)"
        case .parsing: return "Failed to parse response"
        case .unknown: return "Unknown error"
        case .backendError(let data):
            if let apiError = try? JSONDecoder().decode(RegistrationResponse.self, from: data),
               let messages = apiError.errors?.fullMessages {
                return messages.joined(separator: "\n")
            }
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
               let error = apiError.errors{
                return error.joined(separator: "\n")
            }
            return "Data corrupted : Failed to parse response"
        }
    }
}


final class APIClient {
    static let shared = APIClient()
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        session = Session(configuration: configuration)
    }
    
    func request<T: Decodable>(
        _ router: APIRouter,
        responseType: T.Type,
        completion: @escaping (Result<(T, [AnyHashable: Any]), APIError>) -> Void
    ) {
        let url = router.path
        let method = router.method
        let parameters = router.parameters
        AppLogger.general.info("API called \(url))")
        print("parameters = " , parameters as Any)
        print("complete URL = " , router.urlRequest?.url as Any)
        print("method = " , method)
        print("body = " , router.urlRequest?.httpBody as Any)
        session.request(router)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    let headers = response.response?.allHeaderFields ?? [:]
                    completion(.success((value, headers)))
                case .failure(let error):
                    let apiError = self.handleError(error, data: response.data)
                    AppLogger.error.error("error = \(response.debugDescription)")
                    AppLogger.debug.info("data = \(response)")
                    completion(.failure(apiError))
                }
            }
    }
    
    private func handleError(_ error: AFError, data: Data?) -> APIError {
        
        if let data = data, let _ = try? JSONDecoder().decode(RegistrationResponse.self, from: data) {
            return APIError.backendError(data: data)
        }
        if let data = data, let _ = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return APIError.backendError(data: data)
        }
        return APIError.network(description: error.localizedDescription)
    }
}

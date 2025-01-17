//
//  NetworkClient.swift
//  MovieQuiz
//

import Foundation

// MARK: - NetworkRouting
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

// MARK: - NetworkClient
struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
        case emptyData
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data else {
                handler(.failure(NetworkError.emptyData))
                return
            }

            handler(.success(data))
        }

        task.resume()
    }
}

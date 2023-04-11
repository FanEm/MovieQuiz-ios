//
//  MoviesLoader.swift
//  MovieQuiz
//

import Foundation

// MARK: - MoviesLoading
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

// MARK: - MoviesLoader
struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    private let apiKey = "k_6vzv69fy" // TODO: не хранить в коде
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/\(apiKey)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

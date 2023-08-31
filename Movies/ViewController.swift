//
//  ViewController.swift
//  Movies
//
//  Created by Shreeram Bhat on 11/08/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var tableView = UITableView()
    var data = [Movie]()
    
    private var currentPage = 0
    private var shouldStopLoading = false
    
    private var toggleButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
                
        self.tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: String(describing: MovieTableViewCell.self))
        
        self.view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let toggleButton = UIButton(type: .custom)
        toggleButton.addTarget(self, action: #selector(didTapToggle(_:)), for: .touchUpInside)
        toggleButton.setTitle("Top Rated", for: .normal)
        toggleButton.setTitle("Popular", for: .selected)
        toggleButton.setTitleColor(.blue, for: .normal)
        toggleButton.setTitleColor(.black, for: .selected)
        
        self.toggleButton = toggleButton
        
        self.view.addSubview(toggleButton)
        
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            toggleButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
            toggleButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
        
        self.view.bringSubviewToFront(self.toggleButton)
        
        self.getImages()
    }
    
    @objc private func didTapToggle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.currentPage = 0
        self.data = []
        self.getImages()
    }
    
    private func getImages() {
        // https://image.tmdb.org/t/p/w500/ktejodbcdCPXbMMdnpI9BUxW6O8.jpg
                
        if !Reachability.isConnectedToNetwork() {
            self.data = self.getMoviesData()
            
            self.tableView.reloadData()
            
            return
        }
        
        self.currentPage = self.currentPage + 1
        
        let listType = self.toggleButton.isSelected ? "popular" : "top_rated"
                
        let urlString = "https://api.themoviedb.org/3/movie/\(listType)?include_adult=false&include_video=false&language=en-US&page=\(self.currentPage)&sort_by=vote_average.desc&without_genres=99,10755&vote_count.gte=200"
        
        let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1YTNjODRjOTQ3YWI1NGZhZjY1ZTM4OTQzMTNkZTM3OCIsInN1YiI6IjY0YjVmMGIyMGU0ZmM4NTFhMGY0YWQwYSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zvg1q6QECQvbnUy3Ew5HZf8mGCfdmkTEFHhqIh-NbNI"
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.addValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(error)
                
                return
            }
            
            guard let data = data else {
                print("Empty data")
                
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8)
            
            print(jsonString ?? "No json string")
            
            let results = (try? JSONDecoder().decode(Movies.self, from: data).results) ?? []
            
            self.shouldStopLoading = results.isEmpty // resposnse.value?.results.isEmpty ?? true
            
            self.data.append(contentsOf: results)
            
            self.resetAllCoreData()
            
            self.saveMoviesData(self.data)
                        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func saveMoviesData(_ movies: [Movie]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        for movie in movies {
            let newMovie = NSEntityDescription.insertNewObject(forEntityName: "MovieEntity", into: context)
            newMovie.setValue(movie.id, forKey: "id")
            newMovie.setValue(movie.title, forKey: "title")
            newMovie.setValue(movie.poster_path, forKey: "poster_path")
        }
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func getMoviesData() -> [Movie] {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext

        do {
            // Peform Fetch Request
            let movieEntities = try context.fetch(fetchRequest)

            let movies = movieEntities.map { movieEntity in
                return Movie(id: Int(movieEntity.id), title: movieEntity.title ?? "", poster_path: movieEntity.poster_path ?? "")
            }
            
            return movies
        } catch {
            print("Unable to Fetch Workouts, (\(error))")
        }
        
        return []
    }
    
    func resetAllCoreData() {
        // get all entities and loop over them
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let entityNames = appDelegate.persistentContainer.managedObjectModel.entities.map({ $0.name!})
        entityNames.forEach { [weak self] entityName in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            do {
                try appDelegate.persistentContainer.viewContext.execute(deleteRequest)
                try appDelegate.persistentContainer.viewContext.save()
            } catch {
                // error
            }
        }
    }

}

struct Movies: Codable {
    let page: Int
    let results: [Movie]
}

struct Movie: Codable {
    
    let id: Int
    let title: String
    let poster_path: String
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count / 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MovieTableViewCell.self), for: indexPath) as! MovieTableViewCell
        
        let index = indexPath.row * 2
        var nextIndex: Int? = index + 1
        if (nextIndex ?? 0) >= self.data.count {
            nextIndex = nil
        }
        
        let firstImagePath = self.data[index].poster_path
        var secondImagePath: String? = nil
        if let nextIndex = nextIndex {
            secondImagePath = self.data[nextIndex].poster_path
        }
        
        cell.configureCell(firstPath: firstImagePath, secondPath: secondImagePath ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if !self.shouldStopLoading && indexPath.row >= ((self.data.count / 2) - 1) {
            self.getImages()
        }
    }
    
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

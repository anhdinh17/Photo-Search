//
//  ViewController.swift
//  PhotoSearch
//
//  Created by Anh Dinh on 4/1/21.
//

import UIKit

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    private var collectionView: UICollectionView?
 
    
    var results: [Result] = []
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up collectionView kem voi UICollectionViewFlowLayout()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2,
                                 height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        //register the cell used for collectionView
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        // set the collectionView(private) = collectionView we just created above
        self.collectionView = collectionView
        
    }
    
    // add frame to collectionView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(x: 10,
                                 y: view.safeAreaInsets.top,
                                 width: view.frame.size.width - 20,
                                 height: 50)
        
        collectionView?.frame = CGRect(x: 0,
                                       y: view.safeAreaInsets.top + 55,
                                      width: view.frame.size.width,
                                      height: view.frame.size.height - 55)
    }

//MARK: - FetchPhotos func
    func fetchPhotos(query: String){
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=\(query)&client_id=9HF5R0TYi9_vNRNY27qOPPFiuEfTguqqAikr8CyGMHs"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self](data, _, error) in
            guard let data = data, error == nil else{
                return
            }
            
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    // set the array from json = array we created
                    self?.results = jsonResult.results
                    //reload collectionView
                    self?.collectionView?.reloadData()
                }
            }catch{
                print("Error decoding: \(error)")
            }
        }
        
        task.resume()
    }
    
//MARK: - CollectionView codes
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // string URL of image from results array
        let imageURLString = results[indexPath.row].urls.regular
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: imageURLString)
        
        return cell
    }
    
//MARK: - SearchBar Delegate
    // What happens when clicking on the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text {
            // empty the array first
            results = []
            collectionView?.reloadData()
            fetchPhotos(query: text)
        }
    }
}


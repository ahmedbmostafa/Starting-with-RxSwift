//
//  MainViewController.swift
//  RxDemo
//
//  Created by ahmed mostafa on 12/20/20.
//

import UIKit
import RxSwift
import ReactiveSwift
import RxCocoa

class MainViewController: UIViewController {

    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                guard let preview = self?.imagePreview else {return}
                preview.image = UIImage.collage(images: photos, size: preview.frame.size)
                self?.updateUI(photos: photos)
        })
            .disposed(by: bag)
        
//        images.asObservable()
//        .subscribe(onNext: { [weak self] photos in
//        self?.updateUI(photos: photos) })
//        .disposed(by: bag)
    
    }
    
    
    
    
    @IBAction func actionClear() {
        images.accept([])
    }
    
    @IBAction func actionSave() {
     
        guard let image = imagePreview.image else { return }
        
        PhotoWriter.save(image)
          .subscribe(onError: { [weak self] error in
            self?.showMessage("Error", description: error.localizedDescription)
            }, onCompleted: { [weak self] in
              self?.showMessage("Saved")
              self?.actionClear()
          })
          .disposed(by: bag)
        
    }
    
    @IBAction func actionAdd() {
//        let newImages = images.value
//        + [UIImage(named: "IMG_1907.jpg")!]
//        images.accept(newImages)
        
        let photosViewController = storyboard!.instantiateViewController( withIdentifier: "PhotosViewController") as! PhotosViewController
        
        photosViewController.selectedPhotos
            .subscribe(onNext: { [weak self] newImage in
                
                    guard let images = self?.images else { return }
                    images.accept(images.value + [newImage])
                },
            
                onDisposed: {
                  print("completed photo selection")
                }
            
        )
        .disposed(by: bag)
        
        
        navigationController!.pushViewController(photosViewController, animated: true)
        
      }
    
    private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
        
    }
    
    func showMessage(_ title: String, description: String? = nil) {
      showAlert(title: title, description: description)
        .subscribe()
        .disposed(by: bag)
    }

}

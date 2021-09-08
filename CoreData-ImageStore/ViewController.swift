//
//  ViewController.swift
//  CoreData-ImageStore
//
//  Created by Mac HD  on 04/09/21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var imagePicker = UIImagePickerController()
    var newImage: UIImage = UIImage()
    var viewImage: UIImage = UIImage()
    var storedImages: [UIImage] = [UIImage]()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet weak var imagescollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagescollectionView.delegate = self
        fetchImages()
    }
    
    @IBAction func choosebtnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func savebtnClicked() {
        let pngImageData  = newImage.pngData()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entityName =  NSEntityDescription.entity(forEntityName: "ImageEntity", in: managedContext)!
        let image = NSManagedObject(entity: entityName, insertInto: managedContext)
        image.setValue(pngImageData, forKeyPath: "storedImage")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func fetchAndView() {
        fetchImages()
    }
    
    func fetchImages() {
        self.storedImages.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ImageEntity")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                storedImages.append(UIImage(data: data.value(forKey: "storedImage") as! Data) ?? UIImage())
            }
            self.imagescollectionView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCellID", for: indexPath) as! ImageCollectionViewCell
        let img = storedImages[indexPath.row]
        cell.storedimageView.image = img
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storedImages.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 80, height: 80)
//    }
    
}
extension ViewController:  UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        print(newImage.size)
        imageView.image = newImage
        dismiss(animated: true)
    }
}


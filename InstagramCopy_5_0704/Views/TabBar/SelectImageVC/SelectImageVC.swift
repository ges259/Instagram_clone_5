//
//  SelectImageVC.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/08.
//

import UIKit
import Photos

private let reuserIdentifier: String = "SelectePhotoCell"
private let headerIdentifier: String = "SelectePhotoHeader"

final class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Properties
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SelectPhotoVC")
        
        configureNavigationButtons()
        
        
        
        // Register cell classes
        self.collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuserIdentifier)
        self.collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        self.collectionView.backgroundColor = .white
        
        
        fetchPhotos()
        
        
        
    }
    
    
    // MARK: - UICollectionVeiw - FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // spacing = 1
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    // MARK: - UICollectionView - DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        
        if let selectedImage = self.selectedImage {
            // index selected image
            if let index = self.images.index(of: selectedImage) {
                // asset associated with selected image
                let selectedAsses = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsses, targetSize: targetSize, contentMode: .default, options: nil) { image, info in
                    
                    header.photoImageView.image = selectedImage
                }
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserIdentifier, for: indexPath) as! SelectPhotoCell
        
        cell.backgroundColor = .red
        
        cell.photoImageView.image = images[indexPath.row]
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀을 누르면 헤더에 이미가 선택한 이미지로 바뀜
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        
    }
    
    
    
    
    
    // MARK: - Handler
    private func configureNavigationButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    @objc func handleCancel() {
        self.dismiss(animated: true)
    }
    @objc func handleNext() {
        let uploadPostVC = UploadPostVC()
        uploadPostVC.selectedImage = self.header?.photoImageView.image
        uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 0)
        
        self.navigationController?.pushViewController(uploadPostVC, animated: true)
    }
    
    
    
    
    
    
    
    // MARK: - 라이브러리에서 사진 가져오기
    private func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        
        // fetch limit
        options.fetchLimit = 30
        
        // sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        // set sort descriptor for options
        options.sortDescriptors = [sortDescriptor]
        
        return options
    }
    private func fetchPhotos() {
        
        // allPhotos에는 지금 내 사진 앱에 있는 모든 사진들이 들어가 있다.
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        print("SelectImageVC - Running - fetchPhotos()")
        // fetch iamges on background thread
        DispatchQueue.global().async {
            
            // 가져오기 결과의 객체를 열거하는 곳
            // 가져오기 결과의 각 개체를 사용하여 지정된 블록을 생성한다.
            allPhotos.enumerateObjects { asset, count, stop in
                
                // 이미지 메니저 만들기
                let imageManger = PHImageManager.default()
                
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                
                // imageManager를 사용하여 이미지를 요청
                // request image representation for specified asset
                imageManger.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, info in
                                        
                    // 이미지가 존재하는지 확인
                    if let image = image {
                        // 해당 이미지를 데이터소스(images)에 추가한다.
                        // request image to data source
                        self.images.append(image)
                        
                        // assets에 추가
                        // append asset to data source
                        self.assets.append(asset)
                        
                        // requestImage의 첫번째 이미지로 선택한 이미지를 설정
                        // set selected image with first image
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        
                        // 이전까지 각 사진을 개별적으로 가져온다.
                        // 가져와기가 완료되면 collectionView.reload()를 한다.
                            // 카운트가 0부터 시작이기 때문에 마지막 사진의 index는 모든 사진 -1
                        // reload collection view with images once count has completed
                        if count == allPhotos.count - 1 {
                            
                            // reload collection view on main thread
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    

    
    
    
    
}

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
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure UI
        self.configureNavigationButtons()
        self.configureCollectionView()
        
        // fetch - Photos
        self.fetchPhotos()
    }
    
    
    // MARK: - CollectionView
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserIdentifier,
                                                      for: indexPath) as! SelectPhotoCell
            cell.photoImageView.image = self.images[indexPath.row]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀의 이미지를 선택하면 해당 이미지를 selectedImage에 넣음
        self.selectedImage = self.images[indexPath.row]
        
        // collectionView.reloadData()를 통해서 header의 이미지를 바꿈
        // header는 selectedImage에 있는 이미지를 표시함
            // 즉, 셀을 누르면 -> selectedImage가 바뀜 -> 헤더에 이미지가 선택한 이미지로 바뀜
        self.collectionView.reloadData()
        
        // 셀을 클릭하면 -> indexPath - 섹션 0에 item0이 있는 곳으로 자동 이동!!!!!!!!
            // 구현한 이유 : 밑에서 클릭하면 위로 자동으로 올라가서 자신이 선택한 이미지를 크게 볼 수 있음
                    // 만약 0 대신 29를 쓰면 -> 0번째 셀 클릭시 밑으로 내려감!!
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    
    // MARK: - Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerIdentifier,
                                                                     for: indexPath) as! SelectPhotoHeader
        self.header = header
        // collectionView에서 선택한 이미지
        if let selectedImage = self.selectedImage {
            // index selected image
            // collectionView의 0번째 이미지를 header이미지에 표시
            if let index = self.images.firstIndex(of: selectedImage) {
                // asset associated with selected image
                //
                let selectedAssets = self.assets[index]
                
                let imageManager = PHImageManager.default()
                // header 이미지의 크기
                let targetSize = CGSize(width: 600, height: 600)
                // imageManager를 사용하여 이미지를 요청 (asset에게 원하는 사진 1장 요청)
                imageManager.requestImage(for: selectedAssets,
                                          targetSize: targetSize,
                                          contentMode: .default,
                                          options: nil) { image, info in
                    // header의 이미지에 넣기
                    header.photoImageView.image = selectedImage
                }
            }
        }
        return header
    }
    
    
    
    // MARK: - Selectors
    @objc func handleCancel() {
        self.dismiss(animated: true)
    }
    @objc func handleNext() {
        let uploadPostVC = UploadPostVC()
            uploadPostVC.selectedImage = self.header?.photoImageView.image
            uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 0)
        
        self.navigationController?.pushViewController(uploadPostVC, animated: true)
    }
    
    
    
    // MARK: - Helper Functions
    private func configureCollectionView() {
        // Register cell classes
        self.collectionView.register(SelectPhotoCell.self,
                                     forCellWithReuseIdentifier: reuserIdentifier)
        self.collectionView.register(SelectPhotoHeader.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: headerIdentifier)
        // background Color
        self.collectionView.backgroundColor = .white
    }
    
    private func configureNavigationButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.handleNext))
    }
    
    
    
    // MARK: - 라이브러리에서 사진 가져오기
    private func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        
        // sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            // fetch limit
            // 30개의 사진만 가져옴
            options.fetchLimit = 30
            // set sort descriptor for options
            options.sortDescriptors = [sortDescriptor]
        return options
    }
    
    
    
    // MARK: - API
    private func fetchPhotos() {
        // allPhotos에는 지금 내 사진 앱에 있는 모든 사진들이 들어가 있다.
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        // fetch iamges on background thread
        // global-Queue
        DispatchQueue.global().async {
            // 가져오기 결과의 객체를 열거하는 곳
            // 가져오기 결과의 각 개체를 사용하여 지정된 블록을 생성한다.
            allPhotos.enumerateObjects { asset, count, stop in
                // 이미지 메니저 만들기
                let imageManger = PHImageManager.default()
                // 이미지의 크기 조절
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                // 동기식인지 = true
                options.isSynchronous = true
                
                // imageManager를 사용하여 이미지를 요청 (asset에게 요청)
                // request image representation for specified asset
                imageManger.requestImage(for: asset,
                                         targetSize: targetSize,
                                         contentMode: .aspectFit,
                                         options: options) { image, info in
                    // 이미지가 존재하는지 확인
                    if let image = image {
                        // 해당 이미지를 데이터소스(images)에 추가한다. (collectionView를 표시해야하기 때문)
                        // request image to data source
                        self.images.append(image)
                        
                        // assets에 추가 (header에 추가해야 하기 때문)
                        // append asset to data source
                        self.assets.append(asset)
                        
                        // requestImage의 첫번째 이미지로 선택한 이미지를 설정
                        // set selected image with first image
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        // 이전까지 각 사진을 개별적으로 가져온다.
                            // 사진을 모두 가져오면 collectionView.reload()를 하여
                                // collectionView에 표시
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

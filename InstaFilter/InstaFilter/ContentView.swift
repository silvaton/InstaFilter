//
//  ContentView.swift
//  InstaFilter
//
//  Created by Ton Silva on 14/8/23.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI


struct ContentView: View {
    @State private var image: Image?
    @State private var filterValue = 0.5
    @State private var filterPropertyName: String  = "Intensity"
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    private var isButtonsEnabled: Bool {
        if let _ = image {
            return false
        }
        return true
    }
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                HStack {
                    Text(filterPropertyName)
                    Slider(value: $filterValue)
                        .onChange(of: filterValue) { _ in applyProcessing()}
                }
                .padding()
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    .disabled(isButtonsEnabled)
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(isButtonsEnabled)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a Filter", isPresented: $showingFilterSheet) {
                Button("Crystallize") { setFilter(CIFilter.crystallize())}
                Button("Edges") { setFilter(CIFilter.edges())}
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate") { setFilter(CIFilter.pixellate())}
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone())}
                Button("Usharp Mask") { setFilter(CIFilter.unsharpMask())}
                Button("Vignette") { setFilter(CIFilter.vignette())}
                Button("Cancel", role: .cancel) { }
                
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
        
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            self.filterPropertyName = "Intensity"
            currentFilter.setValue(filterValue, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            self.filterPropertyName = "Radius"
            currentFilter.setValue(filterValue * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            self.filterPropertyName = "Scale"
            currentFilter.setValue(filterValue * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

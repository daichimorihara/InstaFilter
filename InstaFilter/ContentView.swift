//
//  ContentView.swift
//  InstaFilter
//
//  Created by Daichi Morihara on 2021/11/11.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.0
    @State private var filterRadius = 0.0
    @State private var filterScale = 0.0
    @State private var showingPicker = false
    @State private var inputImage: UIImage?
    @State private var currentFIlter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage?
    @State private var currentFilters: [CIFilter]?
    @State private var showingSavingAlert = false
    let context = CIContext()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    //select the image
                    showingPicker = true
                }
                HStack {
                    ZStack {
                        Text("Intensity")
                    }
                    .foregroundColor(currentFIlter.inputKeys.contains(kCIInputIntensityKey) ? Color.primary : Color.secondary)
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in applyProcessing() }
                }
                .padding(.top)
                .disabled(!currentFIlter.inputKeys.contains(kCIInputIntensityKey))
                
                
                HStack {
                    ZStack {
                        Text("Intensity").opacity(0)
                        Text("Radius")
                    }
                    .foregroundColor(currentFIlter.inputKeys.contains(kCIInputRadiusKey) ? Color.primary : Color.secondary)
                    
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius) { _ in applyProcessing() }
                }
                .disabled(!currentFIlter.inputKeys.contains(kCIInputRadiusKey))

                HStack {
                    ZStack {
                        Text("Intensity").opacity(0)
                        Text("Scale")
                    }
                    .foregroundColor(currentFIlter.inputKeys.contains(kCIInputScaleKey) ? Color.primary : Color.secondary)
                    
                    Slider(value: $filterScale)
                        .onChange(of: filterScale) { _ in applyProcessing() }
                }
                .padding(.bottom)
                .disabled(!currentFIlter.inputKeys.contains(kCIInputScaleKey))
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    Spacer()
                    Button("Save") {
                        save()
                    }
                    .disabled(image == nil)
                }
                
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("InstaFilter")
            .sheet(isPresented: $showingPicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) {}
            }
            .alert("This picture is saved.", isPresented: $showingSavingAlert) {
                Button("OK") {}
            }
            .onChange(of: currentFIlter) { _ in
                filterIntensity = 0.0
                filterRadius = 0.0
                filterScale = 0.0
            }
            .onChange(of: inputImage) { _ in loadImage()}
        }
    }
    
    func save() {
        guard let processedImage = processedImage else {
            return
        }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = { print("Success") }
        imageSaver.errorHandler = { print("Oops: \($0.localizedDescription)") }
        imageSaver.writeToPhotoAlbum(image: processedImage)
 
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFIlter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    func applyProcessing() {
        let inputKeys = currentFIlter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFIlter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFIlter.setValue(filterRadius*200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) { currentFIlter.setValue(filterScale*100, forKey: kCIInputScaleKey)}
        
        guard let outputImage = currentFIlter.outputImage else { return }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    func setFilter(_ filter: CIFilter) {
        currentFIlter = filter
        loadImage()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

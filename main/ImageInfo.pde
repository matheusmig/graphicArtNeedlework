import java.util.*;

public class ImageInfo {
  PImage image;
  PImage quantizedImage;
  PImage errorQuantizatedImage;
  List<Integer> lstColors; //TODO: Transoformar Lisa em HASH
  
  OctreeQuantizer octree; //Gerencia a paleta de cores quantizadas da imagem
  
  int[] histogram      = new int[256];
  int[] histogramRed   = new int[256];
  int[] histogramGreen = new int[256];
  int[] histogramBlue  = new int[256];
  color[] paletteQuantized;
  
  //Constructor
  public ImageInfo(PImage image) {
    this.image = image;
     
    //Instancia Array de cores
    lstColors  = new ArrayList<Integer>();
    
    //Paleta de cores da imagem
    octree = new OctreeQuantizer();
    
    ProcessImageInfo();
  }
     
  public int ColorsQty(){
   return lstColors.size(); 
  }
  
  //Quantiza imagem
  public PImage quantize(int colorsNumber, boolean do_dithering){
    PImage result = image;
    //Testa se paleta de cores atual já não satisfaz
    if (colorsNumber > lstColors.size()){
      //Nao precisa fazer nada
    } else {
      paletteQuantized = ListToArray(octree.makePalette(colorsNumber));
      if (do_dithering)
        result = quantizeDitheredImage();
      else 
        result = quantizeImage();
    }
    return result;
  }
    
  //Obtém informações da imagem
  private void ProcessImageInfo(){
    if (image != null){
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          int loc = x + y*image.width;
          color c = image.pixels[loc];
          
          // Calcular quantidade de cores
          if (!lstColors.contains(c)){ 
            lstColors.add(c);
          } 
           
          //Adiciona cores no quantizador
          octree.addColor(c);
           
          //Calcula Histogramas
          histogram     [int(brightness(image.pixels[loc]))]++; 
          histogramRed  [int(red(image.pixels[loc]))]++; 
          histogramGreen[int(green(image.pixels[loc]))]++; 
          histogramBlue [int(blue(image.pixels[loc]))]++; 
        }
      } 
    }
  }
  
  //Quantiza uma imagem e ao mesmo tempo gera o erro de quantização
  private PImage quantizeImage() {
    quantizedImage  = createImage(image.width, image.height, RGB);
    
    this.image.loadPixels();
    this.quantizedImage.loadPixels();
    for (int y = 0; y < this.image.height; y++) {
      for (int x = 0; x <this.image.width; x++) {
         int loc = x + y*this.image.width;
         
         color oldColor = this.image.pixels[loc];
         
         //Procura cor, que está na paleta, mais próxima da que estamos lidando
         color newColor = findClosestPaletteColor(paletteQuantized, oldColor);
         this.quantizedImage.pixels[loc] = newColor;
      }
    }
    this.quantizedImage.updatePixels();
    
    return quantizedImage;
  }
  
  //Quantiza uma imagem e faz dithering
  private PImage quantizeDitheredImage() {
    errorQuantizatedImage = createImage(image.width, image.height, RGB);
    errorQuantizatedImage = image.copy();
    
    this.errorQuantizatedImage.loadPixels();
    for (int y = 0; y < this.errorQuantizatedImage.height; y++) {
      for (int x = 0; x <this.errorQuantizatedImage.width; x++) {
         int loc = x + y*this.errorQuantizatedImage.width;
         
         float r = red  (this.errorQuantizatedImage.pixels[loc]);
         float g = green(this.errorQuantizatedImage.pixels[loc]);
         float b = blue (this.errorQuantizatedImage.pixels[loc]);
         
         color oldColor = this.errorQuantizatedImage.pixels[loc];
         
         //Procura cor, que está na paleta, mais próxima da que estamos lidando
         color newColor = findClosestPaletteColor(paletteQuantized, oldColor);
         this.errorQuantizatedImage.pixels[loc] = newColor;
         
         //Calcula o erro de quantização
         float rError = r - red(newColor);
         float gError = g - green(newColor);
         float bError = b - blue(newColor); //<>//
         
         //TODO - IMPLEMENTAR KERNEL DECONVOLUTOIN
         if ((x+1) < this.errorQuantizatedImage.width){ //<>//
           int locAux = (x+1) + y*this.errorQuantizatedImage.width;
           color cAux = this.errorQuantizatedImage.pixels[locAux];
           float redAux   = red(cAux) + (7 * rError) / 16;
           float greenAux = green(cAux) + (7 * gError) /16;
           float blueAux  = blue(cAux) + (7 * bError) / 16;
           this.errorQuantizatedImage.pixels[locAux] = color(redAux, greenAux, blueAux);
         }
         if (((x-1) > 0) && ((y+1) < this.errorQuantizatedImage.height)){
           int locAux = (x-1) + (y+1)*this.errorQuantizatedImage.width;
           color cAux = this.errorQuantizatedImage.pixels[locAux];
           float redAux   = red(cAux) + (3 * rError) / 16;
           float greenAux = green(cAux) + (3 * gError) / 16;
           float blueAux  = blue(cAux) + (3 * bError) / 16;
           this.errorQuantizatedImage.pixels[locAux] = color(redAux, greenAux, blueAux);
         }
         if ((y+1) < this.errorQuantizatedImage.height){
           int locAux = x + (y+1)*this.errorQuantizatedImage.width;
           color cAux = this.errorQuantizatedImage.pixels[locAux];
           float redAux   = red(cAux) + (5 * rError) / 16;
           float greenAux = green(cAux) + (5 * gError) / 16;
           float blueAux  = blue(cAux) + (5 * bError) / 16;
           this.errorQuantizatedImage.pixels[locAux] = color(redAux, greenAux, blueAux);
         }
         if (((x+1) < this.errorQuantizatedImage.width) && ((y+1) < this.errorQuantizatedImage.height)){
           int locAux = (x+1) + (y+1)*this.errorQuantizatedImage.width;
           color cAux = this.errorQuantizatedImage.pixels[locAux];
           float redAux   = red(cAux) + rError / 16;
           float greenAux = green(cAux) + gError /16;
           float blueAux  = blue(cAux) + bError /16;
           this.errorQuantizatedImage.pixels[locAux] = color(redAux, greenAux, blueAux);
         }
      }
    }
    this.errorQuantizatedImage.updatePixels();
    
    return errorQuantizatedImage;
  }
     
     
     
}
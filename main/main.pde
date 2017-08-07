/**
 * basic example of a drop event and its contained informations.
 * drag an image, a file, a folder, a link into the sketch and see
 * what information the console spits out.
 */
import drop.*;

SDrop drop;
PImage originalImage;
PImage resizedImage;
PImage finalImage;

final int FINAL_MAX_HEIGHT = 500;
final int FINAL_MAX_WIDTH = 500;

//SELECTORES
final int GRID_SPACING = 5;
final int MAX_COLOR_PALETTE = 20;

//FLAGS
final boolean DO_DITHERING = true;
final boolean DO_GRAYSCALE = true;
final boolean DRAW_GRID = false;


final int IMAGE_SQUARE_HEIGHT = FINAL_MAX_HEIGHT/ GRID_SPACING;
final int IMAGE_SQUARE_WIDTH  = FINAL_MAX_WIDTH / GRID_SPACING;

void setup() {
  //Create area to drag and drop mages
  size(500, 500);
  frameRate(30);
  drop = new SDrop(this);
  
  // show instructions to user
  fill(255);
  noStroke();
  textSize(18);
  textAlign(CENTER);
  text("Arraste e solte uma imagem para esta area!", width/2, height/2);
  
  
  //apagar tudo abaixo, teste
 
 /* ImageInfo a = new ImageInfo( createTestImage());
  int qt = a.ColorsQty();
  println("color quantity: "+Integer.toString(qt)); 
  a.quantize(128);
  drawImage(a.quantizedImage);
  
  noLoop();*/
  
}


void draw() {
  if (originalImage != null && originalImage.isLoaded()){
    resizedImage = originalImage.copy();

    if (resizedImage.height >= resizedImage.width)
      resizedImage.resize(0,IMAGE_SQUARE_HEIGHT);  
    else
      resizedImage.resize(IMAGE_SQUARE_WIDTH,0);

    // The destination image is created as a blank image the same size as the source.
    finalImage = createImage(resizedImage.width, resizedImage.height, RGB);
    
    resizedImage.loadPixels(); 
    finalImage.loadPixels(); 
    
    ImageInfo a = new ImageInfo(resizedImage);
    int qt = a.ColorsQty();
    println("color quantity: "+Integer.toString(qt)); 
   
    drawImage( a.quantize(MAX_COLOR_PALETTE, DO_DITHERING));

    /*
    //Pixel a pixel - Processa imagem resized
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int loc = x + y*resizedImage.width;
        
        // Obtém cor R,G,B do pixel
        float r = red(resizedImage.pixels[loc]);
        float g = green(resizedImage.pixels[loc]);
        float b = blue(resizedImage.pixels[loc]);
         
        //Processa informação do pixel      
        if (DO_GRAYSCALE) {
          finalImage.pixels[loc] =  color(RGBToGrayScale(r,g,b));    
        } else {
          finalImage.pixels[loc] =  color(r*1,g*1,b);         
        }
      } //<>//
    }
    finalImage.updatePixels(); //inserir algoritmos de color quanization e dithering http://micro.magnet.fsu.edu/primer/java/digitalimaging/processing/colorreduction/index.html
    //quantization: https://www.codeproject.com/Articles/66341/A-Simple-Yet-Quite-Powerful-Palette-Quantizer-in-C
    */
    // Display the destination

    //drawImage(finalImage); 
    if (DRAW_GRID)
      drawGrid();
     
    //Sinaliza que não queremos repetir o loop 
    noLoop();
  }
}


/**************************************************************
                 AUXILIAR FUNCTIONS 
***************************************************************/
void dropEvent(DropEvent theDropEvent) {
  if(theDropEvent.isImage()) {
      println("### loading image ...");
      originalImage = theDropEvent.loadImage();
      loop();
   }
}

// Desenha o grid de linhas na tela
void drawGrid() {
  stroke(0);  
  for (int i = 0; i < width; i+=GRID_SPACING) {
    line (i, 0, i, height);
  }
  for (int i = 0; i < height; i+=GRID_SPACING) {
    line (0, i, width, i);
  }
}

// Desenha a imagem na tela, 
// simulando no grid os pixels da imagem
void drawImage(PImage image) {
  loadPixels();
  image.loadPixels();
  
  //Percorre imagem
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int loc = x + y*image.width;
      
      float r = red  (image.pixels[loc]);
      float g = green(image.pixels[loc]);
      float b = blue (image.pixels[loc]);
      
      // simula pixels na tela
      int windowOffsetHeight = y*GRID_SPACING;
      int windowOffsetWidth  = x*GRID_SPACING;
      
      for (int h = windowOffsetHeight; h < (windowOffsetHeight + GRID_SPACING); h++) {
        for (int w = windowOffsetWidth; w < (windowOffsetWidth + GRID_SPACING); w++) {
          if ((h <= FINAL_MAX_HEIGHT) && (w <= FINAL_MAX_WIDTH)){
            int loc2 = w + h*(FINAL_MAX_WIDTH);
            pixels[loc2] = color(r,g,b); 
          }
        }
      }
    }
  }
  updatePixels();
}
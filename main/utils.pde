// **********************
//      KERNELS
// **********************                            
float[][] kernelFloydSteinberg = {
  {7 / 16, 1, 0},
  {3 / 16, -1, 1},
  {5 / 16, 0, 1},
  {1 / 16, 1, 1}
};
        
float[][] kernelFalseFloydSteinberg = {
  {3 / 8, 1, 0},
  {3 / 8, 0, 1},
  {2 / 8, 1, 1}
};
        
float[][] kernelStucki = {
  {8 / 42, 1, 0},
  {4 / 42, 2, 0},
  {2 / 42, -2, 1},
  {4 / 42, -1, 1},
  {8 / 42, 0, 1},
  {4 / 42, 1, 1},
  {2 / 42, 2, 1},
  {1 / 42, -2, 2},
  {2 / 42, -1, 2},
  {4 / 42, 0, 2},
  {2 / 42, 1, 2},
  {1 / 42, 2, 2}
};
      
float[][] kernelAtkinson ={
  {1 / 8, 1, 0},
  {1 / 8, 2, 0},
  {1 / 8, -1, 1},
  {1 / 8, 0, 1},
  {1 / 8, 1, 1},
  {1 / 8, 0, 2}
};
  
float[][]  kernelfloatJarvis = {      // Jarvis, Judice, and Ninke / JJN?
  {7 / 48, 1, 0},
  {5 / 48, 2, 0},
  {3 / 48, -2, 1},
  {5 / 48, -1, 1},
  {7 / 48, 0, 1},
  {5 / 48, 1, 1},
  {3 / 48, 2, 1},
  {1 / 48, -2, 2},
  {3 / 48, -1, 2},
  {5 / 48, 0, 2},
  {3 / 48, 1, 2},
  {1 / 48, 2, 2}
};
 
float[][] kernelBurkes = {
  {8 / 32, 1, 0},
  {4 / 32, 2, 0},
  {2 / 32, -2, 1},
  {4 / 32, -1, 1},
  {8 / 32, 0, 1},
  {4 / 32, 1, 1},
  {2 / 32, 2, 1},
};
      
float[][] kernelSierra = {
  {5 / 32, 1, 0},
  {3 / 32, 2, 0},
  {2 / 32, -2, 1},
  {4 / 32, -1, 1},
  {5 / 32, 0, 1},
  {4 / 32, 1, 1},
  {2 / 32, 2, 1},
  {2 / 32, -1, 2},
  {3 / 32, 0, 2},
  {2 / 32, 1, 2},
};
     
float[][] kernelTwoSierra = {
  {4 / 16, 1, 0},
  {3 / 16, 2, 0},
  {1 / 16, -2, 1},
  {2 / 16, -1, 1},
  {3 / 16, 0, 1},
  {2 / 16, 1, 1},
  {1 / 16, 2, 1},
};
     
float[][] kernelSierraLite = {
  {2 / 4, 1, 0},
  {1 / 4, -1, 1},
  {1 / 4, 0, 1},
};

/**************************************************************
                    COLOR PALETTES
***************************************************************/
color[] paletteColor1 = {
  #000000, #5C4B51, #8CBEB2, #F2EBBF, #F3B562, #F06060, #FFFFFF
};

color[] paletteColorOranges = {
  #a5a4a0, #c19300, #ba941d, #b59739, #af984d, #baaa75, #bfb699
};

/**************************************************************
                   COLOR FUNCTIONS 
***************************************************************/
float RGBToGrayScale(float R, float G, float B){
  return((0.3 * R) + (0.59 * G) + (0.11 * B));
}

float colorDistance(color C1, color C2){
  float redDistance        = red(C1)        - red(C2);
  float blueDistance       = blue(C1)       - blue(C2);
  float greenDistance      = green(C1)      - green(C2);
  float brightDistance     = brightness(C1) - brightness(C2);
  float hueDistance        = hue(C1)        - hue(C2);
  float saturationDistance = saturation(C1) - saturation(C2);
  float alphaDistance      = alpha(C1)      - alpha(C2);
  return ((redDistance*redDistance) +
          (blueDistance*blueDistance) + 
          (greenDistance*greenDistance)); 
          //(brightDistance*brightDistance) +
          //(hueDistance*hueDistance) +
          //(saturationDistance*saturationDistance) +
          //(alphaDistance*alphaDistance));
}

color colorAdd(color C1, color C2){
  float rAdded = red(C1) + red(C2); //<>//
  float gAdded = green(C1) + green(C2);
  float bAdded = blue(C1) + blue(C2);
  return color(rAdded, gAdded, bAdded);
}

color colorSub(color C1, color C2){
  float rAdded = red(C1) - red(C2);
  float gAdded = green(C1) - green(C2);
  float bAdded = blue(C1) - blue(C2);
  return color(rAdded, gAdded, bAdded);
}


color findClosestPaletteColor(int[] palette, color c){
  float closestDistance = colorDistance(palette[0], c);
  int closestIdx = 0;
  
  for(int i = 1; i < palette.length-1; i++){
    float calculatedDistance = colorDistance(palette[i], c);  
    if ( calculatedDistance < closestDistance ) {
      closestDistance = calculatedDistance; 
      closestIdx = i;
    }
  }
  return palette[closestIdx]; 
}

/**************************************************************
                  CONVOLUTION OPERATION 
***************************************************************/
void imageConvolution(float[][] kernel, int kernelSize, PImage img){
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color c = pixelConvolution(x, y, kernel, kernelSize, img);
      int loc = x + y*img.width;
      img.pixels[loc] = c;
    }
  }
  img.updatePixels();
}

// Faz a convolução de um pixel (x,y) de uma imagem, com um kernel
color pixelConvolution(int x, int y, float[][] kernel, int kernelSize, PImage img){
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = kernelSize / 2;
  for (int i = 0; i < kernelSize; i++){
    for (int j= 0; j < kernelSize; j++){
      // Pega localização do pixel no array
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Garante que não estamos acessando local fora dos limites da image
      loc = constrain(loc,0,img.pixels.length-1);
      // Calculate the convolution
      rtotal += (red(img.pixels[loc]) * kernel[i][j]);
      gtotal += (green(img.pixels[loc]) * kernel[i][j]);
      btotal += (blue(img.pixels[loc]) * kernel[i][j]);
    }
  }
  // Garante que RGB está dentro do limite
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Retorna a cor resultante
  return color(rtotal, gtotal, btotal);
}
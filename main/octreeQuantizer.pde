// https://github.com/delimitry/octree_color_quantizer/blob/master/octree_quantizer.py
 
 //////////////////////////////////////////////////////////////
 // Octree Node class for color quantization
public class OctreeNode {
  int   m_RedColor;
  int   m_GreenColor;
  int   m_BlueColor;
  int   m_PixelCount;
  int   m_PaletteIndex;
  OctreeNode[] m_Childrens;
  
  public OctreeNode(int level, OctreeQuantizer parent){
    m_RedColor      = 0;
    m_GreenColor    = 0;
    m_BlueColor     = 0;
    m_PixelCount    = 0;
    m_PaletteIndex  = 0; 
    m_Childrens     = new OctreeNode[8];
    if (level < OctreeQuantizer.MAX_DEPTH - 1)
      parent.addLevelNode(level, this);
  }
  
  public boolean isLeaf(){
    return (m_PixelCount > 0);
  }
  
  public List<OctreeNode> getLeafNodes(){
    OctreeNode node;
    //Get all leaf nodes
    List<OctreeNode> arrNodes = new ArrayList<OctreeNode>();
    for (int i = 0; i < 8; i++){
      node = m_Childrens[i];
      if (node != null){
        if (node.isLeaf())
          arrNodes.add(node);
        else
          arrNodes.addAll(node.getLeafNodes());
      }
    }
    return arrNodes;
  }

  public int getNodesPixelCount(){
    OctreeNode node;
    int sum = m_PixelCount;
    
    //Get a sum of pixel count for node and its children
    for (int i = 0; i < 8; i++){
      node = m_Childrens[i];
      if (node != null)
        sum += node.m_PixelCount;
    }
    
    return sum;  
  }
  
  public void addColor(color c, int level, OctreeQuantizer parent){
    // Add 'color' to the tree
    
    if (level >= OctreeQuantizer.MAX_DEPTH){
      m_RedColor   += red(c);
      m_GreenColor += green(c);
      m_BlueColor  += blue(c);
      m_PixelCount += 1;
      return;
    } else {
      int index = getColorIndexForLevel(c, level);
      if (m_Childrens[index] == null)
        m_Childrens[index] = new OctreeNode(level, parent);
      m_Childrens[index].addColor(c, level + 1, parent);
    }
  }

  public int getPaletteIndex(color c, int level){
    // Get palette index for 'c'
    // Uses 'level' to go one level deeper if the node is not a leaf
    int result = -1;
    if (isLeaf()){
      result = m_PaletteIndex;
    } else {
      int index = getColorIndexForLevel(c, level);
      if (m_Childrens[index] != null)
        result = m_Childrens[index].getPaletteIndex(c, level + 1);
      else
        //get palette index for a first found child node
        for (int i = 0; i < 8; i++){
          if ((m_Childrens[i] != null) && (result == -1))
            result = m_Childrens[i].getPaletteIndex(c, level + 1);
        }
    }
   if (result == -1)
    return 0;
   else
    return result; //<>//
  }
  
  public int removeLeaves(){
    // Add all children pixels count and color channels to parent node 
    // Return the number of removed leaves
    OctreeNode node; 
    int result = 0;
    for (int i = 0; i < 8; i++){
      node = m_Childrens[i];
      if (node != null){
        m_RedColor   += node.m_RedColor;
        m_GreenColor += node.m_GreenColor;
        m_BlueColor  += node.m_BlueColor;
        m_PixelCount += node.m_PixelCount;
        result += 1;
      }
    }
    return result-1;
  }
  
  public int getColorIndexForLevel(color c, int level){
    // Get index of 'c' for next 'level'
    int index = 0;
    int bitmask = 0x80 >> level;
    if ((Math.round(red(c)) & bitmask) != 0)
      index |= 4;
    if ((Math.round(green(c)) & bitmask) != 0)
      index |= 2;
    if ((Math.round(blue(c)) & bitmask) != 0)
      index |= 1;
      
     return index;
  }
  
  public color getColor(){
    //Get average color
    return color(m_RedColor   / m_PixelCount,
                 m_GreenColor / m_PixelCount,
                 m_BlueColor / m_PixelCount);   
  }
}


 //////////////////////////////////////////////////////////////
 //   Octree Quantizer class for image color quantization
 //   Use MAX_DEPTH to limit a number of levels
public class OctreeQuantizer {
  OctreeNode m_root;
  List<OctreeNode>[] m_arrLevels; 
  
  final static int MAX_DEPTH = 8;
  
  public OctreeQuantizer(){
    m_arrLevels = (ArrayList<OctreeNode>[]) new ArrayList[MAX_DEPTH];
    for(int i = 0; i < MAX_DEPTH; i++)
      m_arrLevels[i] = new ArrayList<OctreeNode>();
    
    m_root      = new OctreeNode(0,this);
  }
  
  public List<OctreeNode> getLeaves(){
    return m_root.getLeafNodes();    
  }
  
  public void addLevelNode(int level, OctreeNode node){
    List<OctreeNode> arrayAux;
    arrayAux = m_arrLevels[level];
    if (arrayAux != null)
      arrayAux.add(node);
     
  }
  
  public void addColor(color c){
    m_root.addColor(c, 0, this); 
  }
  
  public List<Integer> makePalette(int colorCount){
    OctreeNode node;
    
    //Make color palette with `color_count` colors maximum
    List<Integer> palette = new ArrayList<Integer>();
    int  paletteIndex = 0;
    int  leafCount = getLeaves().size();
    
    // reduce nodes
    // up to 8 leaves can be reduced here and the palette will have
    // only 248 colors (in worst case) instead of expected 256 colors
    for (int level = MAX_DEPTH-1; level >= 0; level--){
      if (m_arrLevels[level] != null){
        for (int j = 0; j < m_arrLevels[level].size(); j++){
          node = m_arrLevels[level].get(j);
          leafCount -= node.removeLeaves(); 
          if (leafCount <= colorCount)
            break;
        }
        
        if (leafCount <= colorCount)
          break;
        
        m_arrLevels[level] = null;
      }
    }  
    // build palette
    for (int i = 0; i < getLeaves().size(); i++){
      node = getLeaves().get(i);
          
      if (paletteIndex >= colorCount)
        break;
      if (node.isLeaf())
        palette.add( node.getColor() );
      
      node.m_PaletteIndex = paletteIndex;
      paletteIndex += 1;
    }
    return palette;
  }
  
  public int getPalette(color c){
    //Get palette index for 'c'
    return m_root.getPaletteIndex(c, 0);
  }
  
}

/*  USE EXAMPLE:

 OctreeQuantizer octree = new OctreeQuantizer();

 # add colors to the octree
 for j in xrange(height):
   for i in xrange(width):
     octree.add_color(Color(*pixels[i, j]))

  # 256 colors for 8 bits per pixel output image
  palette = octree.make_palette(256)
*/
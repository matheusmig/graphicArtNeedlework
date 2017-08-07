
//Converte uma Lista dinâmica em um array estático
public color[] ListToArray(List<Integer> list){
  color[] result = new color[list.size()];
  for (int i = 0; i < list.size(); i++) {
    result[i] = list.get(i);
  }
  return result;
}
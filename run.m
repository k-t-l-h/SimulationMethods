function run()
  %матрица стоимостей
  matrix = [
6, 10, 4, 5, 8
8, 10, 7, 9, 11
4, 8, 9, 10, 6
5, 9, 6, 11, 10
6, 11, 6, 3, 9];

  
  %является ли задача задачей максимизации
  maximization = false;
  
  %выводить ли шаги
  show_steps = false;
 
 
 h = HungarianMethod(matrix, maximization, show_steps);
 h.Count();

end

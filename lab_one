function lab1()
  %[a, b] - интервал
  a = 0; 
  b = 1;
  % заданная точность
  eps = 1e-6;
  % вывод x*
  flag = true;
  [n, best, xs] = bitwise_search(a, b, eps);
  draw(a, b, eps, n, best, xs, a, b, 'Поразрядный поиск: ', flag)
end 

% заданная функция, вариант 12
function y = f(x)
    y = exp((x^4 + 2*(x^3)-5*x+6)/5) + cosh(1/(-15*(x^3)+10*x+5*(sqrt(10)))) - 3.0;
end
 
% пересчёт массива
function newArr = get_Y(oldArr)
    newArr = oldArr;
    for i = 1:length(oldArr)
       newArr(i) = f(oldArr(i));
    end
end

% отрисовать результат
function draw(a, b, eps, n, best, xs, ~, ~, text, withPoints)
    %получение минимума
    min_x = [ best ]; 
    min_y = get_Y(min_x);
    
    xs = sort(xs); 
    ys = get_Y(xs);
    
    mi = strcat(' x*: (', sprintf('%.4f', min_x), ', ', sprintf('%.4f', min_y), ')');
    
    t = tiledlayout('flow','TileSpacing','compact');
    nexttile;
    if withPoints
      just_x = xs(1):(xs(end)-xs(1))/100:xs(end); just_y = get_Y(just_x);
      plot(just_x, just_y, '-r', xs, ys, 'or', min_x, min_y, '-*b');
      legend('y = exp(x^4 + 2x^3-5*x+6)/5) + cosh(1/(-15x^3+10x+5*(sqrt(10)))) - 3.0', ...
          'x*i', mi, 'FontSize', 12)
      lgd = legend;
      lgd.Layout.Tile = 2;
    else 
      just_x = a:(b-a)/100:b; just_y = get_Y(just_x);
      plot(just_x, just_y, '-r', min_x, min_y, '-*b');
      legend(' y = exp(x^4 + 2x^3-5*x+6)/5) + cosh(1/(-15x^3+10x+5*(sqrt(10)))) - 3.0', mi, 'FontSize', 12)
      lgd = legend;
      lgd.Layout.Tile = 2;
    end

    grid on; title(text, 'FontSize', 20); 
    xlabel('X', 'FontSize', 18); ylabel('Y', 'FontSize', 18)
    epsNInfo = strcat('eps: ', num2str(eps), ', вычислений функции f(x): ', num2str(n));
    minInfo = strcat('Минимум функции y=', sprintf('%.8f', min_y), ' при x*=', sprintf('%.8f', min_x));
    fprintf(strcat(epsNInfo, '\n'));
    fprintf(strcat(minInfo, '\n'));
    fprintf("x* на i-том шаге: \n");
    i = 1;
    for x = xs
      fprintf(strcat(num2str(i),  ": ",  num2str(x), ",", num2str(f(x)), '\n'));
      i = i + 1;
    end
    fprintf("\n");
end

% Метод поразрядного поиска
function [n, best, xs] = bitwise_search(a, b, e)
    xs = []; % массив точек, приближающих точку искомого минимума
    n = 1; % число вычислений f(x)
    best = 0; % X координата минимума функции
    delta = (b-a) / 4; %шаг точек
    
    x0 = a;
    fx0 = f(a);
    
    while abs(delta) > e % пока не достигли заданной точности
      while x0 >= a && x0 <= b  % пока текущая точка не вышла за пределы интервала
          x1 = x0+delta;
          if x1 > b || x1 < a
            break
          end
          fx1 = f(x1);
          n = n + 1;
          if fx0 > fx1
              x0 = x1;
              fx0 = fx1;
          else
              break
          end
      end
     
      % добавляем новую точку в массив 
      xs = [ xs, x0 ];
      delta = -delta/4;
    end
    best = x0;
    end

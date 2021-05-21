function lab4()
 %[a, b] - интервал
  a = 0; 
  b = 1;
  % заданная точность
  eps = 1e-6;
  % вывод x*
  flag = true;
  [n, best, xs] = NewtonModified(a, b, eps);
  draw(a,b, eps, n, best, xs, flag);
  
  %fun = @(x)(exp((x^4 + 2*(x^3)-5*x+6)/5) + cosh(1/(-15*(x^3)+10*x+5*(sqrt(10)))) - 3.0);
  %options = optimset('PlotFcns',@optimplotfval);
  %[x , y, ~, output] = fminbnd(fun,0,1, options);
  %fprintf(strcat('fminbnd значение функции y=', sprintf('%.8f', y), ', достигается при x=', sprintf('%.8f', x)));
  %fprintf(strcat('fminbnd информация'))
  %output
end

% Заданная функция
function y = f(x)
    y = exp((x^4 + 2*(x^3)-5*x+6)/5) + cosh(1/(-15*(x^3)+10*x+5*(sqrt(10)))) - 3.0;
end
 
% Применение заданной функции для массива
function newArr = get_Y(oldArr)
    newArr = oldArr;
    for i = 1:length(oldArr)
       newArr(i) = f(oldArr(i));
    end 
end

% отрисовать результат
function draw(a, b, eps, n, best, xs, flag)
    min_x = [ best ]; min_y = get_Y(min_x);
    just_x = a:(b-a)/100:b; just_y = get_Y(just_x);
    a_list = []; b_list = [];
    t = tiledlayout('flow','TileSpacing','compact');
    nexttile;
    if flag
      for i=1:length(xs)
        if mod(i, 2) == 0
          a_list = [a_list, xs(i-1)];
          b_list = [b_list, xs(i)];
        end
      end
      
      X = []; Y = zeros(length(a_list), 2);
      for i = 1 : length(a_list)
         Y(i, 1) = a_list(i);
         Y(i, 2) = b_list(i);
         X = [X, i];
      end
    
      stairs(X, Y, '-*');
      xlabel('№ итерации')
      ylabel('X')
      title('Зависимость интервала от № итерации');
      legend('Начало интервала','Конец интервала');
      lgd = legend;
      lgd.Layout.Tile = 2;
    else 
      plot(just_x, just_y, '-r', min_x, min_y, '-*b');
      ylabel('Y', 'FontSize', 18)
      xlabel('X', 'FontSize', 18)
      title('Метод Ньютона')
      mi = strcat('x*: (', sprintf('%.4f', min_x), ', ', sprintf('%.4f', min_y), ')');
      legend('y = exp(x^4+2x^3-5x+6)/5)+cosh(1/(-15x^3+10x+5*sqrt(10))) - 3.0',mi, 'FontSize', 12);
      lgd = legend;
      lgd.Layout.Tile = 2;
    end 
    grid on
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

% Метод нахождения производной центральной конечной разностью
function result = diff1(b)
  h = 1e-5; 
  result = (f(b+h)-f(b-h))/(2*h);
end

% Метод нахождения производной центральной конечной разностью для второй 
% производной
function result = diff2(b)
  h = 1e-5;
  result = (f(b+h)-2*f(b)+f(b-h))/(h^2);
end

% модифицированный метод Ньютона
function [n, best, xs] = NewtonModified(a, b, eps)
  xs = [];
  [n, x, ~] = golden_ratio(a,b, 0.05);
  xs = [xs, x];
  
  f20 = diff2(x); 
  n = n + 3;
  while true
      z = diff1(x); 
      n = n + 2;
      if abs(z) <= eps
        break
      end
      x = x - z/f20;
      xs = [xs, x];
  end
  best = x;
end

% метод золотого сечения
function [n, best, ab] = golden_ratio(a, b, e)
    ab = []; % массив интервалов a,b, содержащих точку искомого минимума
    n = 2;
    best = 0;
    
    fi = (1+sqrt(5))/2;    
    r = (b-a)/fi;
    x1 = b - r;
    x2 = a + r;
    fx1 = f(x1);
    fx2 = f(x2);
    while (b-a) / 2 >= e
      ab = [ ab, [a,b]];
      if fx1 > fx2
        a = x1; 
        x1 = x2;
        fx1 = fx2;
        x2 = b - (x1 - a);
        
        if (b-a) / 2  < e
          break
        end
        fx2 = f(x2);
        n = n + 1;
      else  
        b = x2;
        x2 = x1;
        x1 = a + (b - x2);
        
        if (b-a) / 2 < e
          break
        end
        fx1 = f(x1);
        n = n + 1;
        end
        end
    best = (b+a) / 2;
      end
